import SwiftUI

struct MeterSettings: View {
    @Environment(\.scenePhase) var scenePhase
    let nodeServer: String = Config.nodeServer
    let espConfigUrl: String = Config.espConfigUrl
    let espKnockUrl: String = Config.espKnockUrl
    @State private var broker: String = Config.broker
    @State private var port: String = Config.brokerPort
    @State private var user_id: String = UserDefaults.standard.string(forKey: "user_id") ?? ""
    @State private var ssid: String = UserDefaults.standard.string(forKey: "ssid") ?? ""
    @State private var password: String = UserDefaults.standard.string(forKey: "password") ?? ""
    @State private var username: String = ""
    @State private var mqttpassword: String = ""
    @State private var publishtopic: String = ""
    @State private var subscribetopic: String = ""
    @State private var autoreconnect: Bool = UserDefaults.standard.bool(forKey: "autoreconnect")
    @State private var newDevice: Device? = nil
    @State private var devices: [Device] = []
    @State private var submitMessage: SubmitMessage? = nil
    @State private var isSubmitting: Bool = false
    @State var isESPReachable: Bool = false
    @State var espSearchTimedOut = false
    @State var serverError: String = ""
    @State var waitingForNodeServer: Bool = false
    @State var espServerResponse: String = ""
    @State var isSearchineESP: Bool = false
    
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "house.badge.wifi.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.primary)
                .padding(.top, 40)
            
            // Heading
            Text("Setup your device")
                .font(.title)
                .fontWeight(.bold)
            
            // Live status through checkmarks
            VStack(alignment: .leading, spacing: 10) {
                if waitingForNodeServer {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Creating device in cloud...")
                        ProgressView().scaleEffect(0.8)
                    }.foregroundColor(.gray)
                } else {
                    if serverError.isEmpty {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("New device created!")
                        }
                    } else {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                            Text("An error occurred: \(serverError).")
                        }
                    }
                }
                
                if isESPReachable {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("New device found [\(espServerResponse)]")
                    }
                } else if espSearchTimedOut {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                        Text("No device found.")
                    }
                } else {
                    if isSearchineESP {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Searching device...")
                            ProgressView().scaleEffect(0.8)
                        }.foregroundColor(.gray)
                    } else {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Waiting for device discovery")
                        }.foregroundColor(.gray)
                    }
                    
                }
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            
            ScrollView {
                WifiSetupInstructions()
                
                
                TextField("SSID", text: $ssid)
                SecureField("Password", text: $password)
                Toggle("Auto-Reconnect", isOn: $autoreconnect)
                
                // Save button
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
                
                
                
            }
            
        }
        .onAppear {
            print("onAppear")
            loadDevicesLocally()
            addNewDevice()
        }
        .onChange(of: scenePhase) { newPhase in
            print(newPhase)
            if newPhase == .active {
                if waitingForNodeServer || !serverError.isEmpty {
                    print("restarting adding new device")
                } else {
                    print("device already added successfully on server. Skipping adding new device")
                    if !isESPReachable && (isSearchineESP || espSearchTimedOut) {
                        print("restarting ESP reachability test. isESPReachable: \(isESPReachable)")
                        testESPReachability()
                    }
                }
            }
        }
    } // UI View ends here
    
    
    // Custom functions
    func addNewDevice() {
        waitingForNodeServer = true
        guard let url = URL(string: "\(nodeServer)/add-device") else {
            serverError = "URL exception!"
            waitingForNodeServer = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["user_id": user_id]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    // errorMessage = "Error: \(error.localizedDescription)"
                    serverError = "Error: \(error.localizedDescription)"
                    waitingForNodeServer = false
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    // errorMessage = "No data received"
                    serverError = "No data received!"
                    waitingForNodeServer = false
                }
                return
            }
            
            do {
                newDevice = try JSONDecoder().decode(Device.self, from: data)
                DispatchQueue.main.async {
                    serverError = ""
                    waitingForNodeServer = false
                    devices.append(newDevice!) // TODO: DO NOT Force unwrap!
                    print("new device created on server and saved locally. Total device count: \(devices.count)")
                    saveDeviceArrayLocally(devices: devices)
                    testESPReachability()
                    
                }
            } catch {
                DispatchQueue.main.async {
                    serverError = "Failed to decode response"
                    waitingForNodeServer = false
                }
            }
        }.resume()
    }
    
    func saveDeviceArrayLocally(devices: [Device]) {
        do {
            // Encode devices array into JSON data
            let encodedData = try JSONEncoder().encode(devices)
            // Save the JSON data to UserDefaults
            UserDefaults.standard.set(encodedData, forKey: "savedDevices")
            print("device count after saving: \(devices.count)")
        } catch {
            print("Failed to encode and save devices: \(error.localizedDescription)")
        }
    }
    
    private func loadDevicesLocally() {
        print("UserHome: onAppear: Loading devices locally")
        guard let savedData = UserDefaults.standard.data(forKey: "savedDevices") else {
            print("No saved devices found in UserDefaults.")
            devices = []
            return
        }
        
        do {
            devices = try JSONDecoder().decode([Device].self, from: savedData)
            print("Decoded devices count: \(devices.count)")
//            if devices.isEmpty {
//                errorMessage = "No saved devices."
//                loadDevicesFromServer()
//            }
            print("Devices retrieved successfully from UserDefaults.")
        } catch {
            print("Failed to decode devices from UserDefaults: \(error.localizedDescription)")
            devices = []
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func saveSettingsOnMeter() {
        isSubmitting = true
        submitMessage = nil
        
        // TODO: Do NOT force unwrap newDevice. Handle it gracefully!
        print("saving subscribe topic: \(newDevice!.subscribe_topic)")
        print("saving publish topic: \(newDevice!.publish_topic)")
        
        var parameters: [String: String] = [
            "ssid": ssid,
            "password": password,
            "broker": broker,
            "port": port,
            "username": username,
            "mqttpassword": mqttpassword,
            "subscribetopic": newDevice!.subscribe_topic,
            "publishtopic": newDevice!.publish_topic
        ]
        if autoreconnect {
            parameters["autoreconnect"] = "true"
        }
        
        // Send settings data to ESP
        guard let url = URL(string: espConfigUrl) else {
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
                    // mqttmanager.configureMQTT() // restart mqtt client on ios for saved settings to take effect
                } else {
                    submitMessage = SubmitMessage(text: "Failed to submit configuration.")
                }
            }
        }.resume()
    }
    
    func saveLocalSettings() {
        // save local settings
        UserDefaults.standard.set(ssid, forKey: "ssid")
        UserDefaults.standard.set(password, forKey: "password")
        UserDefaults.standard.set(autoreconnect, forKey: "autoreconnect")
        
        
        // restart mqtt instance to use saved settings
//        mqttmanager.updateTopics(pub: device.publish_topic, sub: device.subscribe_topic)
//        mqttmanager.configureMQTT()
    }
    
    func testESPReachability() {
        // Create a URL for the ESP module's web server
        isSearchineESP = true
        espSearchTimedOut = false
        isESPReachable = false
        espServerResponse = ""
        
        guard let url = URL(string: espKnockUrl) else {
            print("Invalid URL")
            isESPReachable = false
            isSearchineESP = false
            return
        }
        
        // Create a URLSession configuration with a timeout
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10 // Timeout in seconds for the request
        config.timeoutIntervalForResource = 10 // Timeout for the entire resource
        
        let session = URLSession(configuration: config)
        
        // Create a URL session data task to check the connectivity and read response text
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                // Handle error (e.g., no network, unreachable, or timeout)
                if (error as NSError).code == NSURLErrorTimedOut {
                    print("Request timed out")
                    espSearchTimedOut = true
                } else {
                    print("Error: \(error.localizedDescription)")
                }
                isESPReachable = false
                isSearchineESP = false
                return
            }
            
            // Check the HTTP response code
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print("ESP module is reachable!")
                    isESPReachable = true
                    isSearchineESP = false
                    espSearchTimedOut = false
                    // Attempt to read the response data
                    if let responseData = data {
                        if let responseText = String(data: responseData, encoding: .utf8) {
                            print("Response from ESP module: \(responseText)")
                            espServerResponse = responseText
                        } else {
                            print("Unable to decode response text.")
                        }
                    }
                } else {
                    print("ESP module returned an error: \(httpResponse.statusCode)")
                    isESPReachable = false
                    isSearchineESP = false
                    espSearchTimedOut = false
                }
            }
        }
        task.resume()
    }

}

struct SubmitMessage: Identifiable {
    let id = UUID()
    let text: String
}

