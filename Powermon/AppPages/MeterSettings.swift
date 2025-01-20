import SwiftUI

struct MeterSettings: View {
    @StateObject private var deviceApiService = DeviceApiService()
    @StateObject private var espApiService = ESPApiService()
    
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
    @State private var devices: [Device] = []
    @State private var device_id: String = ""
    
    
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
                if deviceApiService.waitingForServerResponse {
                    HStack(alignment: .top, spacing: 10) {
                        ProgressView().scaleEffect(0.8)
                        Text("Adding device to your account. Please wait...")
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil) // Allow unlimited lines
                            .fixedSize(horizontal: false, vertical: true) // Allow wrapping
                    }.foregroundColor(.gray)
                } else {
                    if deviceApiService.message == "New device created on server" {
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
                
                if espApiService.isESPReachable { // Device discovered!
                    HStack(alignment: .top, spacing: 10) {
                        Text("●").foregroundColor(.green)
                        Text("Device discovered in your home network: [\(espApiService.espServerResponse)]")
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil) // Allow unlimited lines
                            .fixedSize(horizontal: false, vertical: true) // Allow wrapping
                    }
                    if deviceApiService.message == "New device created on server" { // Also, device created on backend
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
                            
                            // Sent API request to ESP to add device profile
                            espApiService.saveSettingsOnMeter(ssid: ssid, password: password, broker: broker, port: port, username: username, mqttpassword: mqttpassword, subscribetopic: subscribetopic, publishtopic: publishtopic, user_id: user_id, device_id: device_id, autoreconnect: autoreconnect)
                            
                        }) {
                            if espApiService.isSubmitting {
                                ProgressView()
                            } else {
                                Text("Save")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(.green)
                                    .foregroundColor(.primary)
                                    .cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("TileHeading"), lineWidth: 0.5))
                            }
                        }
                        .padding(.vertical)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .disabled(espApiService.isSubmitting)
                        .alert(item: $espApiService.submitMessage) { message in
                            Alert(title: Text("Configuration Status"), message: Text(message.text), dismissButton: .default(Text("OK")))
                        }
                    }
                    
                } else if espApiService.espSearchTimedOut || !espApiService.espServerError.isEmpty {
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
                    if espApiService.isSearchingESP {
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
            print("MeterSettings: onAppear")
            navigationManager.lastVisitedView = "MeterSettings"
            loadDevicesLocally()
            deviceApiService.addNewDevice(user_id: user_id)
        }
        .onChange(of: deviceApiService.newDevice) { newDevice in
            if let newDevice = newDevice {
                device_id = newDevice.device_id
                subscribetopic = newDevice.subscribe_topic
                publishtopic = newDevice.publish_topic
                
                devices.append(newDevice)
                print("New device created on server and saved locally. Total device count: \(devices.count)")
                saveDeviceArrayLocally(devices: devices)
                espApiService.testESPReachability()
            }
        }
        .onChange(of: espApiService.isESPReachable) { newValue in
            if newValue {
                print("ESP is reachable!")
            } else {
                print("ESP is not reachable.")
            }
        }
        .onChange(of: espApiService.espServerError) { newError in
            if !newError.isEmpty {
                print("Error occurred: \(newError)")
            }
        }
        .onChange(of: scenePhase) { newPhase in
            print(newPhase)
            if newPhase == .active {
                // if the device is not added, then re-trigger device addition when user opens MeterSettings view
                if deviceApiService.waitingForServerResponse || deviceApiService.message != "New device created on server" {
                    print("restarting adding new device")
                } else {
                    print("device already added successfully on server. Skipping adding new device")
                    if !espApiService.isESPReachable && (espApiService.isSearchingESP || espApiService.espSearchTimedOut || !espApiService.espServerError.isEmpty) {
                        print("restarting ESP reachability test. isESPReachable: \(espApiService.isESPReachable)")
                        espApiService.testESPReachability()
                    }
                }
            }
        }
        Spacer()
    } // UI View ends here
    
    
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
        print("MeterSettings: Loading devices locally")
        guard let savedData = UserDefaults.standard.data(forKey: "savedDevices") else {
            print("No saved devices found in UserDefaults.")
            devices = []
            return
        }
        
        do {
            devices = try JSONDecoder().decode([Device].self, from: savedData)
            print("Loaded \(devices.count) devices from UserDefaults.")
        } catch {
            print("Failed to decode devices from UserDefaults: \(error.localizedDescription)")
            devices = []
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func saveLocalSettings() {
        UserDefaults.standard.set(ssid, forKey: "ssid")
        UserDefaults.standard.set(password, forKey: "password")
        UserDefaults.standard.set(autoreconnect, forKey: "autoreconnect")
    }
    
    func openWiFiSettings() {
        if let url = URL(string: "App-prefs:WIFI") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }

}
