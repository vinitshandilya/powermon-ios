import Foundation

class DeviceApiService: ObservableObject {
    @Published var message: String? = nil
    @Published var waitingForServerResponse: Bool = false
    @Published var isError: Bool = false
    @Published var newDevice: Device? = nil
    @Published var devices: [Device] = []
    @Published var deviceNameUpdated: Bool = false
    
    func addNewDevice(user_id: String) {
        self.waitingForServerResponse = true
        guard let url = URL(string: Config.nodeServer.appending("/add-device")) else {
            self.message = "URL exception!"
            self.isError = true
            self.waitingForServerResponse = false
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
                    self.message = "Error: \(error.localizedDescription)"
                    self.isError = true
                    self.waitingForServerResponse = false
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.message = "Error: No data received from server!"
                    self.isError = true
                    self.waitingForServerResponse = false
                }
                return
            }
            
            do {
                let decodedDevice = try JSONDecoder().decode(Device.self, from: data)
                DispatchQueue.main.async {
                    self.newDevice = decodedDevice
                    self.message = "New device created on server"
                    self.isError = false
                    self.waitingForServerResponse = false
                    
                    // Uncomment and use this as needed:
                    // devices.append(decodedDevice)
                    // print("New device created on server and saved locally. Total device count: \(devices.count)")
                    // saveDeviceArrayLocally(devices: devices)
                    // testESPReachability()
                }
            } catch {
                DispatchQueue.main.async {
                    self.message = "Failed to decode response"
                    self.isError = true
                    self.waitingForServerResponse = false
                }
            }
        }.resume()
    }
    
    func loadDevicesFromServer(user_id: String) {
        self.waitingForServerResponse = true
        self.message = "Getting devices from cloud..."
        guard let url = URL(string: "\(Config.nodeServer)/get-devices?user_id=\(user_id)") else {
            DispatchQueue.main.async {
                self.message = "Invalid URL"
                self.isError = true
                self.waitingForServerResponse = false
            }
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.message = "Error: \(error.localizedDescription)"
                    self.isError = true
                    self.waitingForServerResponse = false
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.message = "No data received"
                    self.isError = true
                    self.waitingForServerResponse = false
                }
                return
            }
            
            do {
                if let rawJSON = String(data: data, encoding: .utf8) {
                    print("Raw JSON response: \(rawJSON)")
                }
                
                let decodedResponse = try JSONDecoder().decode([String: [Device]].self, from: data)
                DispatchQueue.main.async {
                    self.isError = false
                    self.waitingForServerResponse = false
                    if let fetchedDevices = decodedResponse["devices"], !fetchedDevices.isEmpty {
                        self.devices = fetchedDevices
                        self.message = "Devices fetched successfully"
                    } else {
                        self.message = "No devices found"
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.message = "Failed to decode response: \(error.localizedDescription)"
                    self.isError = true
                    self.waitingForServerResponse = false
                }
            }
        }.resume()
    }
    
    
    func updateDeviceName(user_id: String, device_id: String, newName: String) {
        self.waitingForServerResponse = true
        self.message = "Updating device name."
        guard let url = URL(string: Config.nodeServer.appending("/update-device-name")) else {
            self.waitingForServerResponse = false
            self.isError = true
            self.message = "Invalid URL"
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: String] = [
            "user_id": user_id,
            "device_id": device_id,
            "device_name": newName
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Failed to serialize JSON: \(error)")
            self.waitingForServerResponse = false
            self.isError = true
            self.message = "Failed to serialize JSON: \(error)"
            return
        }
        
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error updating device name: \(error.localizedDescription)")
                    self.waitingForServerResponse = false
                    self.isError = true
                    self.message = "Error updating device name: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    self.waitingForServerResponse = false
                    self.isError = true
                    self.message = "Failed to update device name: Invalid response"
                    print("Failed to update device name: Invalid response")
                    return
                }
                
                guard let data = data else {
                    self.waitingForServerResponse = false
                    self.isError = true
                    self.message = "No data received from server"
                    print("No data received from server")
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let message = json["message"] as? String {
                        self.waitingForServerResponse = false
                        self.isError = false
                        self.message = "Device name updated"
                        self.deviceNameUpdated = true
                        print("Server Response: \(message)")
                        print("Refreshing device list..")
                        // deviceApiService.loadDevicesFromServer(user_id: user_id)
                    } else {
                        self.waitingForServerResponse = false
                        self.isError = true
                        self.message = "Failed to parse server response"
                        print("Failed to parse server response")
                    }
                } catch {
                    self.waitingForServerResponse = false
                    self.isError = true
                    self.message = "Error decoding response: \(error)"
                    print("Error decoding response: \(error)")
                }
            }
        }.resume()
    }
    
    
    func deleteDeviceFromServer(user_id: String, device: Device) {
        self.waitingForServerResponse = true
        self.message = "Deleting device from cloud."
        guard let url = URL(string: "\(Config.nodeServer)/delete-device") else {
            print("Invalid URL")
            self.waitingForServerResponse = false
            self.isError = true
            self.message = "Invalid URL"
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
            self.waitingForServerResponse = false
            self.isError = true
            self.message = "Failed to serialize JSON: \(error)"
            return
        }
        
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error deleting device: \(error.localizedDescription)")
                    self.waitingForServerResponse = false
                    self.isError = true
                    self.message = "Error deleting device: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Failed to delete device: Invalid response")
                    self.waitingForServerResponse = false
                    self.isError = true
                    self.message = "Failed to delete device: Invalid response"
                    return
                }
                
                guard let data = data else {
                    print("No data received from server")
                    self.waitingForServerResponse = false
                    self.isError = true
                    self.message = "No data received from server"
                    return
                }
                
                do {
                    // Parse the response JSON
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let devicesData = json["devices"] {
                        // Convert the devices array into Data
                        let devicesJSON = try JSONSerialization.data(withJSONObject: devicesData, options: [])
                        // Decode the devices array into [Device]
                        self.devices = try JSONDecoder().decode([Device].self, from: devicesJSON)
                        self.waitingForServerResponse = false
                        self.isError = false
                        self.message = "Device deleted successfully"
                        
//                        saveDeviceArrayLocally(devices: devices)
                        print("Devices after deletion: \(self.devices)")
                    } else {
                        self.waitingForServerResponse = false
                        self.isError = true
                        self.message = "Failed to parse response JSON"
                        print("Failed to parse response JSON")
                    }
                } catch {
                    self.waitingForServerResponse = false
                    self.isError = true
                    self.message = "Error decoding response: \(error)"
                    print("Error decoding response: \(error)")
                }
            }
        }.resume()
    }
    
    
    
}
