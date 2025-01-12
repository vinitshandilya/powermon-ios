import SwiftUI

struct HomeTab: View {
    @StateObject var mqttmanager = MQTTManager()
    @Environment(\.scenePhase) var scenePhase
    @State private var devices: [Device] = []
    @State private var errorMessage: String? = nil
    @State private var user_id: String = UserDefaults.standard.string(forKey: "user_id") ?? ""
    @State private var username: String = UserDefaults.standard.string(forKey: "username") ?? ""
    @State private var waitingForServerResponse: Bool = false
    @State private var editingDeviceID: String? = nil
    @State private var newDeviceName: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var waitMessage: String = "Please wait."
    @StateObject private var navigationManager = NavigationManager()
    
    
    var body: some View {
        NavigationView {
            VStack {
                if devices.isEmpty {
                    ScrollView {
                        LazyVGrid(
                            columns: [GridItem(.adaptive(minimum: 150), spacing: 10)], // Column spacing
                            spacing: 10 // Row spacing
                        ) {
                            NavigationLink(destination: MeterSettings().environmentObject(navigationManager)) {
                                AddNewDeviceButton()
                            }
                        }
                        .padding()
                        
                        Spacer()
                        
                        Text(errorMessage ?? "No devices found")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .padding()
                    }
                    .refreshable {
                        loadDevicesFromServer()
                    }
                    
                } else {
                    ScrollView {
                        LazyVGrid(
                            columns: [GridItem(.adaptive(minimum: 150), spacing: 20)], // Column spacing
                            spacing: 20 // Row spacing
                        ) {
                            ForEach(devices.indices, id: \.self) { index in
                                let device = devices[index]
                                NavigationLink(
                                    destination: DeviceDetails(device: device, mqttmanager: mqttmanager)
                                        .environmentObject(navigationManager)
                                ) {
                                    DeviceButtonTile(
                                        device: device,
                                        editingDeviceID: $editingDeviceID,
                                        newDeviceName: $newDeviceName,
                                        mqttmanager: mqttmanager,
                                        updateDeviceName: updateDeviceName,
                                        deleteDeviceFromServer: deleteDeviceFromServer
                                    )
                                    .onLongPressGesture {
                                        
                                    }
                                }
                            }
                            
                            // Add new device button
                            NavigationLink(destination: MeterSettings().environmentObject(navigationManager)) {
                                AddNewDeviceButton()
                            }
                        }
                        .padding() // Adds padding around the entire grid
                    }
                    .refreshable {
                        loadDevicesFromServer()
                    }
                    
                }
                
                if waitingForServerResponse {
                    ProgressSpinner(progressText: waitMessage)
                } else {
                    if !mqttmanager.isMqttConnected {
                        ProgressSpinner(progressText: "Waiting for cloud connection...")
                    } else if !mqttmanager.isMqttSubscribed {
                        ProgressSpinner(progressText: "Connected! Waiting for data")
                    }
                }
            }
            .padding(.top)
            .onAppear {
                print("HomeTab: onAppear")
                if navigationManager.lastVisitedView == "Root" || navigationManager.lastVisitedView == "MeterSettings" {
                    print("Connecting to MQTT")
                    DispatchQueue.global().async {
                        mqttmanager.connectToMqtt()
                    }
                }
                loadDevicesLocally()
                print(devices.count)
                navigationManager.lastVisitedView = "HomeTab"
            }
            .onChange(of: scenePhase) { newPhase in
                print("HomeTab: \(newPhase)")
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(Color("NavbarItemsColor"))
                        .font(.title2)
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Welcome, \(username)")
                        .font(.headline)
                        .foregroundColor(Color("NavbarItemsColor"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        logoutUser()
                    }) {
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundColor(Color("NavbarItemsColor"))
                            .font(.title2)
                    }
                }
            }
        }
        .tabItem {
            TabItem(text: "Home", icon: "house")
        }

    }
    
    private func loadDevicesLocally() {
        guard let savedData = UserDefaults.standard.data(forKey: "savedDevices") else {
            print("No saved devices found in UserDefaults.")
            devices = []
            return
        }
        
        do {
            devices = try JSONDecoder().decode([Device].self, from: savedData)
            if devices.isEmpty {
                errorMessage = "No saved devices."
                loadDevicesFromServer()
            }
        } catch {
            print("Failed to decode devices from UserDefaults: \(error.localizedDescription)")
            devices = []
        }
    }
    
    func navigateToLoginPage() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            print("Failed to get the key window")
            return
        }
        
        window.rootViewController = UIHostingController(rootView: LoginView())
        window.makeKeyAndVisible()
    }
    
    private func saveDeviceArrayLocally(devices: [Device]) {
        do {
            // Encode devices array into JSON data
            let encodedData = try JSONEncoder().encode(devices)
            // Save the JSON data to UserDefaults
            UserDefaults.standard.set(encodedData, forKey: "savedDevices")
            print("Devices saved successfully to UserDefaults.")
        } catch {
            print("Failed to encode and save devices: \(error.localizedDescription)")
        }
    }
    
    private func loadDevicesFromServer() {
        waitingForServerResponse = true
        waitMessage = "Getting your devices from cloud."
        guard let url = URL(string: "\(Config.nodeServer)/get-devices?user_id=\(user_id)") else {
            errorMessage = "Invalid URL"
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Error: \(error.localizedDescription)"
                    waitingForServerResponse = false
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "No data received"
                    waitingForServerResponse = false
                }
                return
            }
            
            do {
                
                if let rawJSON = String(data: data, encoding: .utf8) {
                    print("Raw JSON response: \(rawJSON)")
                }
                
                let decodedResponse = try JSONDecoder().decode([String: [Device]].self, from: data)
                DispatchQueue.main.async {
                    print(data)
                    waitingForServerResponse = false
                    if let fetchedDevices = decodedResponse["devices"], fetchedDevices.isEmpty {
                        errorMessage = "No devices found"
                    } else {
                        devices = decodedResponse["devices"] ?? []
                        saveDeviceArrayLocally(devices: devices)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Failed to decode response: \(error.localizedDescription)"
                    waitingForServerResponse = false
                }
            }
            
        }.resume()
    }
    
    func updateDeviceName(deviceID: String, deviceName: String) {
        waitingForServerResponse = true
        waitMessage = "Updating device name."
        guard let url = URL(string: Config.nodeServer.appending("/update-device-name")) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: String] = [
            "user_id": user_id,
            "device_id": deviceID,
            "device_name": deviceName
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Failed to serialize JSON: \(error)")
            waitingForServerResponse = false
            return
        }
        
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error updating device name: \(error.localizedDescription)")
                    waitingForServerResponse = false
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    waitingForServerResponse = false
                    print("Failed to update device name: Invalid response")
                    return
                }
                
                guard let data = data else {
                    waitingForServerResponse = false
                    print("No data received from server")
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let message = json["message"] as? String {
                        waitingForServerResponse = false
                        print("Server Response: \(message)")
                        print("Refreshing device list..")
                        loadDevicesFromServer()
                    } else {
                        waitingForServerResponse = false
                        print("Failed to parse server response")
                    }
                } catch {
                    waitingForServerResponse = false
                    print("Error decoding response: \(error)")
                }
            }
        }.resume()
    }
    
    
    func deleteDeviceFromServer(device: Device) {
        waitingForServerResponse = true
        waitMessage = "Deleting device from cloud."
        guard let url = URL(string: "\(Config.nodeServer)/delete-device") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: String] = [
            "user_id": user_id,
            "device_id": device.device_id
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Failed to serialize JSON: \(error)")
            waitingForServerResponse = false
            return
        }
        
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error deleting device: \(error.localizedDescription)")
                    waitingForServerResponse = false
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Failed to delete device: Invalid response")
                    waitingForServerResponse = false
                    return
                }
                
                guard let data = data else {
                    waitingForServerResponse = false
                    print("No data received from server")
                    return
                }
                
                do {
                    // Parse the response JSON
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let devicesData = json["devices"] {
                        // Convert the devices array into Data
                        let devicesJSON = try JSONSerialization.data(withJSONObject: devicesData, options: [])
                        // Decode the devices array into [Device]
                        devices = try JSONDecoder().decode([Device].self, from: devicesJSON)
                        
                        // Save devices locally
                        saveDeviceArrayLocally(devices: devices)
                        waitingForServerResponse = false
                        print("Devices after deletion: \(devices)")
                    } else {
                        waitingForServerResponse = false
                        print("Failed to parse response JSON")
                    }
                } catch {
                    waitingForServerResponse = false
                    print("Error decoding response: \(error)")
                }
            }
        }.resume()
    }
    
    private func logoutUser() {
        // TODO: cancel all network tasks to prevent unexpected response when logged in as a different user, while old network call is still waiting for a server response.
        saveDeviceArrayLocally(devices: []) // clear devices from local storage
        UserDefaults.standard.set("", forKey: "user_id") // clear saved user id
        UserDefaults.standard.set("", forKey: "username") // clear saved username
        navigateToLoginPage()
    }
}
