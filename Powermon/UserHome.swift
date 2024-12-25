import SwiftUI

struct Device: Identifiable, Decodable {
    let id = UUID()
    let device_id: String
    let subscribe_topic: String
    let publish_topic: String
    let lower_limit: Int
    let upper_limit: Int
}

struct UserHome: View {
    @StateObject var mqttmanager = MQTTManager()
    @State private var devices: [Device] = []
    @State private var errorMessage: String? = nil
    @State private var user_id: String = UserDefaults.standard.string(forKey: "user_id") ?? ""
    @State private var isModalPresented: Bool = false
    @State private var newDevice: Device? = nil
    
    @State private var subscribetopic: String = "intopic"
    @State private var publishtopic: String = "outtopic"
    
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
                                        Text("Device ID:")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text(device.device_id)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        Text("Subscribe Topic:")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text(device.subscribe_topic)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        Text("Publish Topic:")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text(device.publish_topic)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        
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
            }
            .navigationTitle("Devices")
            .onAppear(perform: fetchDevices)
            .sheet(isPresented: $isModalPresented) {
                // pass new device bundle to Settings page for further configuration.
                if let newDevice = newDevice {
                    SettingsTab(device: newDevice, mqttmanager: mqttmanager, newonboarding: true)
                }
            }
        }
    }
    
    private func fetchDevices() {
        mqttmanager.configureMQTT()
        guard let url = URL(string: "http://192.168.1.52:3000/get-devices?user_id=\(user_id)") else {
            errorMessage = "Invalid URL"
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Error: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "No data received"
                }
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode([String: [Device]].self, from: data)
                DispatchQueue.main.async {
                    devices = decodedResponse["devices"] ?? []
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Failed to decode response"
                }
            }
        }.resume()
    }
    
    private func addNewDevice() {
        // get deviceid from server
        guard let url = URL(string: "http://192.168.1.52:3000/add-device") else {
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
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "No data received"
                }
                return
            }
            
            do {
                let newDevice = try JSONDecoder().decode(Device.self, from: data)
                DispatchQueue.main.async {
                    self.newDevice = newDevice
                    self.devices.append(newDevice)
                    self.isModalPresented = true
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Failed to decode response"
                }
            }
        }.resume()
    }
}


/*
 1. When the page loads, it sends an API call to get the list of all devices for user_id:
 curl -X GET "http://192.168.1.52:3000/get-devices?user_id=d22264a5-75ef-4cae-830f-0727c3911bf6" -H "Content-Type: application/json"
 The response is like below:
 {"devices":[{"device_id":"e9a2d5fa-d0f3-47d6-91ae-9a31e2307c2a","subscribe_topic":"d22264a5-75ef-4cae-830f-0727c3911bf6/e9a2d5fa-d0f3-47d6-91ae-9a31e2307c2a/intopic","publish_topic":"d22264a5-75ef-4cae-830f-0727c3911bf6/e9a2d5fa-d0f3-47d6-91ae-9a31e2307c2a/outtopic","lower_limit":500,"upper_limit":1000}]}
 
 2. Display these devices in a grid. Use label and text to display the results in the grid. This grid will be empty if the server does not return any response. Display "No devices found" text in such case.
 
 3. Create a button "Add new device" with a '+' icon.
 
 4. When user clicks on "Add new device", below API call should be sent to server for user_id:
 curl -X POST http://192.168.1.52:3000/add-device  -H "Content-Type: application/json" -d '{"user_id": "d22264a5-75ef-4cae-830f-0727c3911bf6"}'
 Response has a single device:
 {"device_id":"58ad6ce8-de94-45cd-ae8f-cd2c0f73b122","subscribe_topic":"d22264a5-75ef-4cae-830f-0727c3911bf6/58ad6ce8-de94-45cd-ae8f-cd2c0f73b122/intopic","publish_topic":"d22264a5-75ef-4cae-830f-0727c3911bf6/58ad6ce8-de94-45cd-ae8f-cd2c0f73b122/outtopic","lower_limit":500,"upper_limit":1000}
 
 5. After receiving the response, add it in the device grid.
 
 
 */
