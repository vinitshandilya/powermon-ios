import SwiftUI

struct MeterSettings: View {
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var navigationManager: NavigationManager
    @Environment(\.dismiss) private var dismiss
    @State private var broker: String = Config.broker
    @State private var port: String = Config.brokerPort
    @State private var user_id: String = UserDefaults.standard.string(forKey: "user_id") ?? ""
    @State private var ssid: String = UserDefaults.standard.string(forKey: "ssid") ?? ""
    @State private var password: String = UserDefaults.standard.string(forKey: "password") ?? ""
    @State private var username: String = Config.mqttuser
    @State private var mqttpassword: String = Config.mqttpassword
    @State private var publishtopic: String = ""
    @State private var subscribetopic: String = ""
    @State private var autoreconnect: Bool = UserDefaults.standard.bool(forKey: "autoreconnect")
    @State private var newDevice: Device? = nil
    @State private var devices: [Device] = []
    @State private var submitMessage: SubmitMessage? = nil
    @State private var isSubmitting: Bool = false
    @State var isESPReachable: Bool = false
    @State var espSearchTimedOut = false
    @State var nodeServerError: String = ""
    @State var espServerError: String = ""
    @State var waitingForNodeServer: Bool = false
    @State var espServerResponse: String = ""
    @State var isSearchingESP: Bool = false
    
    
    var body: some View {
        ScrollView {
            Image(systemName: "house.badge.wifi.fill")
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.primary)
                .padding(.top, 40)
            
            // Heading
            Text("Add New Device")
                .font(.title)
                .fontWeight(.bold)
            
            // Live status through checkmarks
            VStack(alignment: .leading, spacing: 10) {
                if waitingForNodeServer {
                    HStack(alignment: .top, spacing: 10) {
                        ProgressView().scaleEffect(0.8)
                        Text("Adding device to your account. Please wait...")
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil) // Allow unlimited lines
                            .fixedSize(horizontal: false, vertical: true) // Allow wrapping
                    }.foregroundColor(.gray)
                } else {
                    if nodeServerError.isEmpty {
                        HStack(alignment: .top, spacing: 10) {
                            Text("●").foregroundColor(.green)
                            Text("Success! Device added to your account.")
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil) // Allow unlimited lines
                                .fixedSize(horizontal: false, vertical: true) // Allow wrapping
                        }
                    } else {
                        HStack(alignment: .top, spacing: 10) {
                            Text("●").foregroundColor(.red)
                            Text("There was an issue adding your device. Please check your connection.")
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil) // Allow unlimited lines
                                .fixedSize(horizontal: false, vertical: true) // Allow wrapping
                        }
                    }
                }
                
                if isESPReachable { // Device discovered!
                    HStack(alignment: .top, spacing: 10) {
                        Text("●").foregroundColor(.green)
                        Text("Device discovered in your home network: [\(espServerResponse)]")
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil) // Allow unlimited lines
                            .fixedSize(horizontal: false, vertical: true) // Allow wrapping
                    }
                    if nodeServerError.isEmpty { // Also, device created on backend
                        Text("Connect your device to your home network. It will reboot automatically once the setup is complete.")
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil) // Allow unlimited lines
                            .fixedSize(horizontal: false, vertical: true) // Allow wrapping
                            .padding(.vertical)
                        
                        HStack {
                            Label("Name", systemImage: "wifi") // SF Symbol for Wi-Fi
                                .frame(width: 100, alignment: .leading)
                            TextField("Network Name", text: $ssid)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.leading)
                        }
                        
                        HStack {
                            Label("Password", systemImage: "lock.fill") // SF Symbol for lock
                                .frame(width: 100, alignment: .leading)
                            SecureField("Network Password", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.leading)
                        }
                        
                        HStack {
                            Label("Auto-Reconnect", systemImage: "arrow.triangle.2.circlepath") // SF Symbol for auto-reconnect
                                .frame(alignment: .leading)
                            Toggle("", isOn: $autoreconnect)
                                .toggleStyle(SwitchToggleStyle())
                        }
                        
                        
                        Button(action: {
                            hideKeyboard()
                            saveLocalSettings()
                            saveSettingsOnMeter()
                        }) {
                            if isSubmitting {
                                ProgressView()
                            } else {
                                Text("Save")
                                    .padding()
                                    .background(Color("Tile3"))
                                    .foregroundColor(.primary)
                                    .cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("TileHeading"), lineWidth: 0.5))
                            }
                        }
                        .padding(.vertical)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .disabled(isSubmitting)
                        .alert(item: $submitMessage) { message in
                            Alert(title: Text("Configuration Status"), message: Text(message.text), dismissButton: .default(Text("OK")))
                        }
                    }
                    
                } else if espSearchTimedOut || !espServerError.isEmpty {
                    HStack(alignment: .top, spacing: 10) {
                        Text("●").foregroundColor(.red)
                        Text("No nearby devices found. Please follow the steps below to manually add a device to your home network.")
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil) // Allow unlimited lines
                            .fixedSize(horizontal: false, vertical: true) // Allow wrapping
                    }
                    .padding(.bottom)
                    
                    HStack(alignment: .top, spacing: 10) {
                        Text("●")
                        Text("Tap the Setup button on device and wait until the LED glows solid blue.")
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil) // Allow unlimited lines
                            .fixedSize(horizontal: false, vertical: true) // Allow wrapping
                    }
                    HStack(alignment: .top, spacing: 10) {
                        Text("●")
                        Text("Connect to the device's access point - \"pzem_AP\". The default password is '12345678910'.")
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil) // Allow unlimited lines
                            .fixedSize(horizontal: false, vertical: true) // Allow wrapping
                    }
                    Button(action: openWiFiSettings) {
                        Text("Open Wi-Fi Settings")
                            .padding()
                            .background(Color("Tile3"))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("TileHeading"), lineWidth: 0.5))
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical)
                    
                    Text("To restart the setup, switch the device back to setup mode and try again.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    
                } else {
                    if isSearchingESP {
                        HStack(alignment: .top, spacing: 10) {
                            // Image(systemName: "checkmark.circle.fill")
                            ProgressView().scaleEffect(0.8)
                            Text("Finding nearby devices in your network.")
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil) // Allow unlimited lines
                                .fixedSize(horizontal: false, vertical: true)
                            
                        }.foregroundColor(.gray)
                    } else {
                        HStack(alignment: .top, spacing: 10) {
                            Text("●")
                            Text("Waiting for device discovery.")
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil) // Allow unlimited lines
                                .fixedSize(horizontal: false, vertical: true) // Allow wrapping
                            Spacer() // Push the text to wrap
                        }.foregroundColor(.gray)
                    }
                    
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // Custom back button
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(Color.primary)
                }
            }
        }
        .onAppear {
            print("onAppear")
            loadDevicesLocally()
            addNewDevice()
            navigationManager.lastVisitedView = "MeterSettings"
        }
        .onChange(of: scenePhase) { newPhase in
            print(newPhase)
            if newPhase == .active {
                if waitingForNodeServer || !nodeServerError.isEmpty { // TODO: What if the device addition fails. Need to restart adding device
                    print("restarting adding new device")
                } else {
                    print("device already added successfully on server. Skipping adding new device")
                    if !isESPReachable && (isSearchingESP || espSearchTimedOut || !espServerError.isEmpty) {
                        print("restarting ESP reachability test. isESPReachable: \(isESPReachable)")
                        testESPReachability()
                    }
                }
            }
        }
        Spacer()
    } // UI View ends here
    
    
    // Custom functions
    func addNewDevice() {
        waitingForNodeServer = true
        guard let url = URL(string: Config.nodeServer.appending("/add-device")) else {
            nodeServerError = "URL exception!"
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
                    nodeServerError = "Error: \(error.localizedDescription)"
                    waitingForNodeServer = false
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    // errorMessage = "No data received"
                    nodeServerError = "No data received!"
                    waitingForNodeServer = false
                }
                return
            }
            
            do {
                newDevice = try JSONDecoder().decode(Device.self, from: data)
                DispatchQueue.main.async {
                    nodeServerError = ""
                    waitingForNodeServer = false
                    devices.append(newDevice!) // TODO: DO NOT Force unwrap!
                    print("new device created on server and saved locally. Total device count: \(devices.count)")
                    saveDeviceArrayLocally(devices: devices)
                    testESPReachability()
                    
                }
            } catch {
                DispatchQueue.main.async {
                    nodeServerError = "Failed to decode response"
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
            "publishtopic": newDevice!.publish_topic,
            "user_id": user_id,
            "device_id": newDevice!.device_id
        ]
        if autoreconnect {
            parameters["autoreconnect"] = "true"
        }
        
        // Send settings data to ESP
        guard let url = URL(string: Config.espServer.appending("/setconfig")) else {
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
                } else {
                    submitMessage = SubmitMessage(text: "Failed to submit configuration.")
                }
            }
        }.resume()
    }
    
    func saveLocalSettings() {
        UserDefaults.standard.set(ssid, forKey: "ssid")
        UserDefaults.standard.set(password, forKey: "password")
        UserDefaults.standard.set(autoreconnect, forKey: "autoreconnect")
    }
    
    func testESPReachability() {
        // Create a URL for the ESP module's web server
        isSearchingESP = true
        espSearchTimedOut = false
        isESPReachable = false
        espServerResponse = ""
        espServerError = ""
        
        guard let url = URL(string: Config.espServer.appending("/knock")) else {
            print("Invalid URL")
            isESPReachable = false
            isSearchingESP = false
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
                isESPReachable = false
                isSearchingESP = false
                if (error as NSError).code == NSURLErrorTimedOut {
                    espServerError = "Request timed out"
                    print(espServerError)
                    espSearchTimedOut = true
                } else {
                    espServerError = "\(error.localizedDescription)"
                    print("Error: \(error.localizedDescription)")
                }
                return
            }
            
            // Check the HTTP response code
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print("ESP module is reachable!")
                    isESPReachable = true
                    isSearchingESP = false
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
                    isSearchingESP = false
                    espSearchTimedOut = false
                    espServerError = "\(httpResponse.statusCode)"
                }
            }
        }
        task.resume()
    }
    
    func openWiFiSettings() {
        if let url = URL(string: "App-prefs:WIFI") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }

}

struct SubmitMessage: Identifiable {
    let id = UUID()
    let text: String
}

