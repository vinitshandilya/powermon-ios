import SwiftUI

struct DeviceDetails: View {
    @Environment(\.scenePhase) var scenePhase // detects application lifecycle
    @StateObject var mqttmanager = MQTTManager()
    let device: Device
    @State private var isPresentingConfirm: Bool = false
    @State private var nominalUsage: String = UserDefaults.standard.string(forKey: "nominalUsage") ?? "500"
    @State private var maximumUsage: String = UserDefaults.standard.string(forKey: "maximumUsage") ?? "1000"

    var body: some View {
        VStack {
            ConnStatusBar(status: mqttmanager.reading.level)

            HStack {
                if mqttmanager.isMqttConnected {
                    Label("Connected", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    HStack {
                        ProgressView().scaleEffect(0.8)
                        Text("Connecting...")
                    }
                    .foregroundColor(.gray)
                }
                Spacer()
            }
            .font(.footnote)
            .padding()

            HStack {
                Label("Power", systemImage: "bolt.circle").fontWeight(.heavy)
                Spacer()
                Text(String(mqttmanager.reading.power)).fontWeight(.light) + Text(" W").fontWeight(.light)
            }
            HStack {
                Label("Voltage", systemImage: "powerplug").fontWeight(.heavy)
                Spacer()
                Text(String(mqttmanager.reading.voltage)).fontWeight(.light) + Text(" V").fontWeight(.light)
            }
            HStack {
                Label("Current", systemImage: "alternatingcurrent").fontWeight(.heavy)
                Spacer()
                Text(String(mqttmanager.reading.current)).fontWeight(.light) + Text(" A").fontWeight(.light)
            }
            HStack {
                Label("Units", systemImage: "barometer").fontWeight(.heavy)
                Spacer()
                Text(String(mqttmanager.reading.energy)).fontWeight(.light) + Text(" kWh").fontWeight(.light)
            }
            HStack {
                Label("Freq", systemImage: "waveform").fontWeight(.heavy)
                Spacer()
                Text(String(mqttmanager.reading.frequency)).fontWeight(.light) + Text(" Hz").fontWeight(.light)
            }
            HStack {
                Label("PF", systemImage: "poweroff").fontWeight(.heavy)
                Spacer()
                Text(String(mqttmanager.reading.pf)).fontWeight(.light)
            }
            
            
            VStack(alignment: .leading) {
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
        .navigationTitle(device.device_name)
        .onAppear {
            print("onAppear")
            if !mqttmanager.isMqttConnected {
                mqttmanager.updateTopics(pub: device.publish_topic, sub: device.subscribe_topic)
                
                DispatchQueue.global().async {
                    mqttmanager.configureMQTT()
                }
                
                // mqttmanager.configureMQTT()
            }
        }
        .onDisappear() {
            print("DevicePage went to background. Stopping MQTT client.")
            if mqttmanager.isMqttConnected {
                mqttmanager.disconnectMQTT()
                print("MQTT client stopped")
            } else {
                print("MQTT client never connected!")
            }
        }
        .onChange(of: scenePhase) { newPhase in
            print(newPhase)
            if newPhase == .active {
                if !mqttmanager.isMqttConnected {
                    mqttmanager.updateTopics(pub: device.publish_topic, sub: device.subscribe_topic)
                    // mqttmanager.configureMQTT()
                    DispatchQueue.global().async {
                        mqttmanager.configureMQTT()
                    }
                }
            }
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

