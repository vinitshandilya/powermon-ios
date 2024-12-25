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
    private var nodeServer: String = "https://wattwise-k1f5.onrender.com"
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
        guard let url = URL(string: "\(nodeServer)/get-devices?user_id=\(user_id)") else {
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
                
                if let rawJSON = String(data: data, encoding: .utf8) {
                    print("Raw JSON response: \(rawJSON)")
                }
                
                let decodedResponse = try JSONDecoder().decode([String: [Device]].self, from: data)
                DispatchQueue.main.async {
                    print(data)
                    if let fetchedDevices = decodedResponse["devices"], fetchedDevices.isEmpty {
                        errorMessage = "No devices found"
                    } else {
                        devices = decodedResponse["devices"] ?? []
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Failed to decode response: \(error.localizedDescription)"
                }
            }

        }.resume()
        
        // Ensure this does not interfere with the data fetch
        DispatchQueue.global().async {
            mqttmanager.configureMQTT()
        }
    }
    
    private func addNewDevice() {
        // get deviceid from server
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
    
    private func logoutUser() {
        UserDefaults.standard.set("", forKey: "user_id")
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
}
