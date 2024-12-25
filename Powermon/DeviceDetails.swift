import SwiftUI

struct DeviceDetails: View {
    @Environment(\.scenePhase) var scenePhase // detects application lifecycle
    @StateObject var mqttmanager = MQTTManager()
    @State private var isSettingsPresented = false // State to control the modal sheet
    let device: Device

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

            Form {
                Section(header: Text("Live reading")) {
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
                }
            }
            .font(.footnote)

            // Add "Settings" Text
            Text("Settings")
                .font(.footnote)
                .foregroundColor(.blue)
                .padding(.top, 10)
                .onTapGesture {
                    isSettingsPresented = true
                }
                .sheet(isPresented: $isSettingsPresented) {
                    SettingsTab(device: device, mqttmanager: mqttmanager, newonboarding: false)
                }
        }
        .navigationTitle("WattWise")
        .onAppear {
            print("onAppear")
            if !mqttmanager.isMqttConnected {
                mqttmanager.updateTopics(pub: device.publish_topic, sub: device.subscribe_topic)
                mqttmanager.configureMQTT()
            }
        }
        .onChange(of: scenePhase) { newPhase in
            print(newPhase)
            if newPhase == .active {
                if !mqttmanager.isMqttConnected {
                    mqttmanager.updateTopics(pub: device.publish_topic, sub: device.subscribe_topic)
                    mqttmanager.configureMQTT()
                }
            }
        }
    }
}

