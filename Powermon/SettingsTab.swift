import SwiftUI

struct SettingsTab: View {
    var nodeServer: String = "https://wattwise-k1f5.onrender.com"
    let device: Device
    let mqttmanager: MQTTManager
    let newonboarding: Bool
    
    @State private var user_id: String = UserDefaults.standard.string(forKey: "user_id") ?? ""
    
    // Fields for user input
    @State private var ssid: String = UserDefaults.standard.string(forKey: "ssid") ?? ""
    @State private var password: String = UserDefaults.standard.string(forKey: "password") ?? ""
    // @State private var broker: String = UserDefaults.standard.string(forKey: "broker") ?? "broker.hivemq.com"
    // @State private var port: String = UserDefaults.standard.string(forKey: "port") ?? "1883"
    // @State private var username: String = UserDefaults.standard.string(forKey: "username") ?? ""
    // @State private var mqttpassword: String = UserDefaults.standard.string(forKey: "mqttpassword") ?? ""
    
    @State private var broker: String = "broker.hivemq.com"
    @State private var port: String = "1883"
    @State private var username: String = ""
    @State private var mqttpassword: String = ""
    
    @State private var autoreconnect: Bool = UserDefaults.standard.bool(forKey: "autoreconnect")
    @State private var isSubmitting: Bool = false
    @State private var submitMessage: SubmitMessage? = nil
    @State private var isPresentingConfirm: Bool = false
    @State private var nominalUsage: String = UserDefaults.standard.string(forKey: "nominalUsage") ?? "500"
    @State private var maximumUsage: String = UserDefaults.standard.string(forKey: "maximumUsage") ?? "1000"
    
    var body: some View {
        ScrollView {
            WifiSetupInstructions()
            VStack {
                TextField("SSID", text: $ssid)
                SecureField("Password", text: $password)
//                TextField("Broker Address", text: $broker)
//                TextField("Port", text: $port)
//                    .keyboardType(.numberPad)
//                TextField("Username", text: $username)
//                SecureField("MQTT Password", text: $mqttpassword)
                Toggle("Auto-Reconnect", isOn: $autoreconnect)
                Button(action: {
                    hideKeyboard()
                    saveLocalSettings()
                    saveSettingsOnMeter()
                }) {
                    if isSubmitting {
                        ProgressView()
                    } else {
                        Text("Save Configuration on Device")
                    }
                }
                .disabled(isSubmitting)
                .alert(item: $submitMessage) { message in
                    Alert(title: Text("Configuration Status"), message: Text(message.text), dismissButton: .default(Text("OK")))
                }
                
                if !newonboarding {
                    Section(header: Text("Set Limits")) {
                        TextField("Nominal Usage", text: $nominalUsage)
                            .keyboardType(.numberPad)
                        TextField("Maximum Usage", text: $maximumUsage)
                            .keyboardType(.numberPad)
                        Button(action: {
                            // Extract the values and send them as comma-separated
                            if let nominal = Double(nominalUsage), let maximum = Double(maximumUsage) {
                                UserDefaults.standard.set(nominalUsage, forKey: "nominalUsage")
                                UserDefaults.standard.set(maximumUsage, forKey: "maximumUsage")
                                
                                let message = "\(nominal),\(maximum)"
                                mqttmanager.sendMessage(topic: device.subscribe_topic, message: message)
                                hideKeyboard()
                            } else {
                                print("Invalid threshold values")
                            }
                        }) {
                            Text("Set Limits")
                        }
                    }
                    
                    
                    Button("Reset KWh", role: .destructive) {
                        isPresentingConfirm = true
                    }
                    .confirmationDialog("Are you sure?", isPresented: $isPresentingConfirm) {
                        // publishing "1" on intopic will reset the module
                        Button("Reset usage?", role: .destructive) { mqttmanager.sendMessage(topic: device.subscribe_topic, message: "1")}
                    }
                    message: {
                        Text("Usage will be reset. You cannot undo this")
                    }
                    
                }
            }
            .padding()
        }
    }
    
    func saveLocalSettings() {
        // save local settings
        UserDefaults.standard.set(ssid, forKey: "ssid")
        UserDefaults.standard.set(password, forKey: "password")
//        UserDefaults.standard.set(broker, forKey: "broker")
//        UserDefaults.standard.set(Int(port), forKey: "port")
//        UserDefaults.standard.set(username, forKey: "username")
//        UserDefaults.standard.set(mqttpassword, forKey: "mqttpassword")
        UserDefaults.standard.set(autoreconnect, forKey: "autoreconnect")
        
        
        // restart mqtt instance to use saved settings
        mqttmanager.updateTopics(pub: device.publish_topic, sub: device.subscribe_topic)
        mqttmanager.configureMQTT()
    }
    
    func saveSettingsOnMeter() {
        isSubmitting = true
        submitMessage = nil
        
        print("saving subscribe topic: \(device.subscribe_topic)")
        print("saving publish topic: \(device.publish_topic)")
        
        var parameters: [String: String] = [
            "ssid": ssid,
            "password": password,
            "broker": broker,
            "port": port,
            "username": username,
            "mqttpassword": mqttpassword,
            "subscribetopic": device.subscribe_topic,
            "publishtopic": device.publish_topic
        ]
        if autoreconnect {
            parameters["autoreconnect"] = "true"
        }
        
        // Send settings data to ESP
        guard let url = URL(string: "http://nodemcu.local/setconfig") else {
            submitMessage = SubmitMessage(text: "Invalid server URL.")
            isSubmitting = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("close", forHTTPHeaderField: "Connection") // Ensure connection closure
        // request.timeoutInterval = 10 // Adjust timeout interval
        
        let body = parameters.compactMap { key, value in
            value.isEmpty ? nil : "\(key)=\(value)"
        }.joined(separator: "&")
        request.httpBody = body.data(using: .utf8)
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isSubmitting = false
                if let error = error {
                    submitMessage = SubmitMessage(text: "Error: \(error.localizedDescription)")
                    return
                }
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    submitMessage = SubmitMessage(text: "Configuration submitted successfully.")
                    print("restarting mqtt client on ios")
                    mqttmanager.configureMQTT() // restart mqtt client on ios for saved settings to take effect
                } else {
                    submitMessage = SubmitMessage(text: "Failed to submit configuration.")
                }
            }
        }.resume()
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct SubmitMessage: Identifiable {
    let id = UUID()
    let text: String
}

