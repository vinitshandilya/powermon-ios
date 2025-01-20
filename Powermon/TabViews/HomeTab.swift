import SwiftUI

struct HomeTab: View {
    @StateObject var mqttmanager: MQTTManager
    @StateObject private var deviceApiService = DeviceApiService()
    
    @Environment(\.scenePhase) var scenePhase
    @State private var devices: [Device] = []
    @State private var errorMessage: String? = nil
    @State private var user_id: String = UserDefaults.standard.string(forKey: "user_id") ?? ""
    @State private var username: String = UserDefaults.standard.string(forKey: "username") ?? ""
    @State private var email: String = UserDefaults.standard.string(forKey: "email") ?? ""
    @State private var editingDeviceID: String? = nil
    @State private var newDeviceName: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var showDeviceDetails: Bool = false
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .center) {
                    Text("Hi, \(username)")
                    Text("👋")
                }
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("\(email)")
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
            if devices.isEmpty && !deviceApiService.waitingForServerResponse {
                EmptyDeviceView()
            } else {
                ScrollView {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 150), spacing: 20)], // Column spacing
                        spacing: 20 // Row spacing
                    ) {
                        ForEach(devices.indices, id: \.self) { index in
                            let device = devices[index]
                            
                            NavigationLink(value: device) {
                                DeviceButtonTile(
                                    device: device,
                                    editingDeviceID: $editingDeviceID,
                                    newDeviceName: $newDeviceName,
                                    mqttmanager: mqttmanager,
                                    updateDeviceName: deviceApiService.updateDeviceName,
                                    deleteDeviceFromServer: deviceApiService.deleteDeviceFromServer
                                )
                            }
                        }
                    }
                    .padding(.all, 20)
                }
                .refreshable {
                    deviceApiService.loadDevicesFromServer(user_id: user_id)
                }
            }

            if deviceApiService.waitingForServerResponse {
                ProgressSpinner(progressText: deviceApiService.message ?? "Please wait...")
            }
            
            if !(mqttmanager.isMqttConnected && mqttmanager.isMqttSubscribed) {
                ProgressSpinner(progressText: "Waiting for cloud connection...")
            }
        }
        .onAppear {
            print("HomeTab: onAppear")
            print("navigation path: \(navigationManager.navigationPath)")
            // Reconnect to MQTT only when starting first or when meter settings are changed for new device
            if navigationManager.lastVisitedView == "Root" || navigationManager.lastVisitedView == "MeterSettings" {
                print("Connecting to MQTT")
                DispatchQueue.global().async {
                    mqttmanager.connectToMqtt()
                }
            }
            loadDevicesLocally()
            navigationManager.lastVisitedView = "HomeTab"
        }
        .onChange(of: deviceApiService.devices) { fetchedDevices in
            devices = fetchedDevices
            saveDeviceArrayLocally(devices: devices)
            loadDevicesLocally()
        }
        .onChange(of: deviceApiService.deviceNameUpdated) { isNameUpdated in
            if isNameUpdated {
                print("Device name updated. Reloading devices...")
                deviceApiService.loadDevicesFromServer(user_id: user_id)
            }
        }
        .onChange(of: mqttmanager.isMqttConnected) { isconnected in
            print("HomeTab: MQTT connection changed to \(isconnected)")
        }
        .onChange(of: mqttmanager.isMqttSubscribed) { issubscribed in
            print("HomeTab: MQTT subscription changed to \(issubscribed)")
        }
        .navigationDestination(for: Device.self) { device in
            DeviceDetails(device: device, mqttmanager: mqttmanager)
                .environmentObject(navigationManager)
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
            print("Loaded device count: \(devices.count)")
            if devices.isEmpty {
                errorMessage = "No saved devices."
                deviceApiService.loadDevicesFromServer(user_id: user_id)
            }
        } catch {
            print("Failed to decode devices from UserDefaults: \(error.localizedDescription)")
            devices = []
        }
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
    
}
