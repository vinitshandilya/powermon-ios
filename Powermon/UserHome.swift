import SwiftUI

struct UserHome: View {
    private var nodeServer: String = "https://wattwise-k1f5.onrender.com"
    @StateObject var mqttmanager = MQTTManager()
    @State private var devices: [Device] = []
    @State private var errorMessage: String? = nil
    @State private var user_id: String = UserDefaults.standard.string(forKey: "user_id") ?? ""
    @State private var isModalPresented: Bool = false
    @State private var newDevice: Device? = nil
    @State private var subscribetopic: String = "intopic"
    @State private var publishtopic: String = "outtopic"
    @State private var waitingForServerResponse: Bool = false
    
    @State private var editingDeviceID: String? = nil
    @State private var newDeviceName: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if devices.isEmpty {
                    Text(errorMessage ?? "No devices found")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                            ForEach(devices) { device in
                                NavigationLink(destination: DeviceDetails(device: device)) {
                                    VStack(alignment: .leading) {
                                        Text("Device Name:")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        if editingDeviceID == device.device_id {
                                            TextField("Enter new name", text: $newDeviceName, onCommit: {
                                                updateDeviceName(deviceID: device.device_id, deviceName: newDeviceName)
                                                editingDeviceID = nil
                                            })
                                            .font(.body)
                                            .foregroundColor(.primary)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .onTapGesture {
                                                if newDeviceName.isEmpty {
                                                    newDeviceName = device.device_name // Prepopulate the text field
                                                }
                                            }
                                        } else {
                                            Text(device.device_name)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                        }
                                        
                                        // Hamburger menu for each device
                                        HStack {
                                            Spacer()
                                            Menu {
                                                Button(action: {
                                                    editingDeviceID = device.device_id
                                                    newDeviceName = device.device_name
                                                }) {
                                                    Label("Rename", systemImage: "pencil")
                                                }
                                                Button(action: {
                                                    deleteDeviceFromServer(device: device)
                                                }) {
                                                    Label("Delete", systemImage: "trash")
                                                        .foregroundColor(.red)
                                                }
                                            } label: {
                                                Image(systemName: "ellipsis.circle")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(.primary)
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(Color(UIColor.systemGray6))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                    }
                }
                
                if(waitingForServerResponse) {
                    HStack {
                        ProgressView().scaleEffect(0.8)
                        Text("Please wait...")
                    }
                    .foregroundColor(.gray)
                }
                
                Text("Refresh")
                    .font(.footnote)
                    .foregroundColor(.blue)
                    .padding(.top, 10)
                    .onTapGesture {
                        print("Loading devices from server")
                        loadDevicesFromServer()
                    }
                
                Button(action: addNewDevice) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add New Device")
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                // Logout link
                Text("Logout")
                    .font(.footnote)
                    .foregroundColor(.blue)
                    .padding(.top, 10)
                    .onTapGesture {
                        print("Logged out")
                        logoutUser()
                    }
            }
            .navigationTitle("WattWise")
            .onAppear(perform: loadDevicesLocally) // Load saved devices
            .sheet(isPresented: $isModalPresented) {
                // pass new device bundle to Settings page for further configuration.
                if let newDevice = newDevice {
                    SettingsTab(device: newDevice, mqttmanager: mqttmanager, newonboarding: true)
                }
            }
        }
    }
    
    private func loadDevicesLocally() {
        guard let savedData = UserDefaults.standard.data(forKey: "savedDevices") else {
            print("No saved devices found in UserDefaults.")
            devices = []
            return
        }
        
        do {
            // Decode the data into a [Device] array
            devices = try JSONDecoder().decode([Device].self, from: savedData)
            if devices.isEmpty {
                errorMessage = "No devices found locally. Getting devices from server..."
                loadDevicesFromServer()
            }
//            print("Devices retrieved successfully from UserDefaults.")
        } catch {
            print("Failed to decode devices from UserDefaults: \(error.localizedDescription)")
            devices = []
        }
    }
    
    private func addNewDevice() {
        waitingForServerResponse = true
        guard let url = URL(string: "\(nodeServer)/add-device") else {
            errorMessage = "Invalid URL"
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
                let newDevice = try JSONDecoder().decode(Device.self, from: data)
                DispatchQueue.main.async {
                    waitingForServerResponse = false
                    self.newDevice = newDevice
                    self.devices.append(newDevice)
                    saveDeviceArrayLocally(devices: self.devices)
                    self.isModalPresented = true
                }
            } catch {
                DispatchQueue.main.async {
                    waitingForServerResponse = false
                    errorMessage = "Failed to decode response"
                }
            }
        }.resume()
    }
    
    private func logoutUser() {
        saveDeviceArrayLocally(devices: []) // clear devices from local storage
        UserDefaults.standard.set("", forKey: "user_id") // clear saved user id
        navigateToLoginPage()
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
        guard let url = URL(string: "\(nodeServer)/get-devices?user_id=\(user_id)") else {
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
        
        // Ensure this does not interfere with the data fetch
        DispatchQueue.global().async {
            mqttmanager.configureMQTT()
        }
    }
    
    func updateDeviceName(deviceID: String, deviceName: String) {
        waitingForServerResponse = true
        guard let url = URL(string: "https://wattwise-k1f5.onrender.com/update-device-name") else {
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
        guard let url = URL(string: "\(nodeServer)/delete-device") else {
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
    //    private func saveSingleDeviceLocally(newDevice: Device) {
    //        // Retrieve existing devices from UserDefaults
    //        loadDevicesLocally()
    //
    //        // Add the new device to the array
    //        devices.append(newDevice)
    //
    //        // Save the updated array back to UserDefaults
    //        do {
    //            let encodedData = try JSONEncoder().encode(devices)
    //            UserDefaults.standard.set(encodedData, forKey: "savedDevices")
    //            print("Device added and saved successfully to UserDefaults.")
    //        } catch {
    //            print("Failed to encode and save the device: \(error.localizedDescription)")
    //        }
    //    }
    
    
    
}
