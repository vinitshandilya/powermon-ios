import SwiftUI

struct DeviceDetails: View {
    let device: Device
    @Environment(\.scenePhase) var scenePhase // detects application lifecycle
    @StateObject var mqttmanager = MQTTManager()
    @ObservedObject var chartViewModel = PowerDataViewModel()
    @State private var selectedTab = 0
    @State private var slideOffset: CGFloat = -150
    @State private var user_id: String = UserDefaults.standard.string(forKey: "user_id") ?? ""
    @State private var isResetDialogShowing: Bool = false
    @State private var nominalUsage: Double = UserDefaults.standard.double(forKey: "nominalUsage") == 0 ? 500 : UserDefaults.standard.double(forKey: "nominalUsage")
    @State private var maximumUsage: Double = UserDefaults.standard.double(forKey: "maximumUsage") == 0 ? 1000 : UserDefaults.standard.double(forKey: "maximumUsage")
    @State private var isLevelSetDialogShowing = false
    
    
    var body: some View {
        
        NavigationView {
            VStack {
                SemiCircularChart(value: mqttmanager.reading.power, minValue: nominalUsage, maxValue: maximumUsage, isMqttConnected: mqttmanager.isMqttConnected)
                HStack(alignment: .top, spacing: 10) {
                    VStack {
                        HStack {
                            Label("Units", systemImage: "powermeter")
                            Spacer()
                            Text(String(mqttmanager.reading.energy)).fontWeight(.light) + Text(" kWh").fontWeight(.light)
                        }
                        HStack {
                            Label("Voltage", systemImage: "powerplug.portrait")
                            Spacer()
                            Text(String(mqttmanager.reading.voltage)).fontWeight(.light) + Text(" Volts").fontWeight(.light)
                        }
                        HStack {
                            Label("Current", systemImage: "alternatingcurrent")
                            Spacer()
                            Text(String(mqttmanager.reading.current)).fontWeight(.light) + Text(" Amp").fontWeight(.light)
                        }
                        HStack {
                            Label("Nominal", systemImage: "lessthanorequalto.circle")
                            Spacer()
                            Text(String(nominalUsage)).fontWeight(.light) + Text(" W").fontWeight(.light)
                        }
                    }
                    
                    Spacer()
                    
                    VStack {
                        HStack {
                            Label("Frequency", systemImage: "waveform")
                            Spacer()
                            Text(String(mqttmanager.reading.frequency)).fontWeight(.light) + Text(" Hz").fontWeight(.light)
                        }
                        HStack {
                            Label("Power Factor", systemImage: "angle")
                            Spacer()
                            Text(String(mqttmanager.reading.pf)).fontWeight(.light)
                        }
                        HStack {
                            Label("Usage", systemImage: "leaf.circle")
                            Spacer()
                            Text(String(mqttmanager.reading.level)).fontWeight(.light)
                        }
                        HStack {
                            Label("Alarm", systemImage: "greaterthanorequalto.circle")
                            Spacer()
                            Text(String(maximumUsage)).fontWeight(.light) + Text(" W").fontWeight(.light)
                        }
                    }
                    
                }
                .font(.footnote)
                .padding()
                
                
                // Tabs:
                TabView(selection: $selectedTab) {
                    // First Tab for hourly trend
                    VStack(alignment: .center, spacing: 20) {
                        Text("Hourly Usage")
                            .font(.title3)
                            .padding()
                        
                        if chartViewModel.chartpoints.isEmpty {
                            Text("Loading...")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        } else {
                            // Chart Bars
                            HStack(alignment: .bottom, spacing: 5) {
                                ForEach(chartViewModel.chartpoints) { reading in
                                    VStack {
                                        Text("\(reading.power) W    ")
                                            .font(.footnote)
                                            .rotationEffect(.degrees(90))
                                            .fixedSize()
                                            .frame(width: 40, alignment: .center)
                                        Rectangle()
                                            .fill(Color.green)
                                            .frame(width: 20, height: CGFloat(reading.power) / 10) // Scale the power
                                        Text(formatTime(reading.timestamp))
                                            .font(.caption)
                                            .rotationEffect(.degrees(90))
                                            .padding(.top)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 10) // Rounded rectangle as background
                            .fill(Color("CardBg")) // Card color
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5) // Add shadow
                    )
                    .tag(0)
                    
                    
                    // Second tab for daily trend
                    Text("Days")
                        .tag(1)
                    
                    // Third tab for weekly trend
                    Text("Weeks")
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .indexViewStyle(.page(backgroundDisplayMode: .never))
                .onChange(of: selectedTab) { newValue in
                    print("Current page: \(newValue)")
                }
                
                HStack(alignment: .center, spacing: 10) {
                    selectedTab == 0 ? Text("●").foregroundColor(.green) : Text("●").foregroundColor(.gray)
                    selectedTab == 1 ? Text("●").foregroundColor(.green) : Text("●").foregroundColor(.gray)
                    selectedTab == 2 ? Text("●").foregroundColor(.green) : Text("●").foregroundColor(.gray)
                }
                .font(.footnote)
                
                
                
                
                
                
            }
            .confirmationDialog("Are you sure?", isPresented: $isResetDialogShowing) {
                Button("Reset usage?", role: .destructive) { mqttmanager.sendMessage(topic: device.subscribe_topic, message: "1")}
            }
            message: {
                Text("Usage will be reset. You cannot undo this")
            }
            
        }
        .navigationTitle(device.device_name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        print("Billing configuration")
                    }) {
                        Label("Billing", systemImage: "coloncurrencysign.circle")
                    }
                    
                    Button(action: {
                        isLevelSetDialogShowing = true
                    }) {
                        Label("Set Levels", systemImage: "slider.horizontal.2.arrow.trianglehead.counterclockwise")
                    }
                    
                    Button(role: .destructive, action: {
                        isResetDialogShowing = true
                    }) {
                        Label("Reset kWh", systemImage: "arrow.clockwise.circle")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .imageScale(.large)
                        .foregroundColor(.gray)
                        .padding(10)
                        .contentShape(Rectangle())
                }
            }
        }
        .sheet(isPresented: $isLevelSetDialogShowing) {
            SetLevelsDialog(
                nominalUsage: $nominalUsage,
                maximumUsage: $maximumUsage,
                onSave: { nominal, maximum in
                    // Save to UserDefaults
                    UserDefaults.standard.set(nominal, forKey: "nominalUsage")
                    UserDefaults.standard.set(maximum, forKey: "maximumUsage")
                    
                    // Send via MQTT
                    let message = "\(Int(nominal)),\(Int(maximum))"
                    mqttmanager.sendMessage(topic: device.subscribe_topic, message: message)
                }
            )
        }
        .onAppear {
            print("onAppear")
            chartViewModel.fetchPowerData(userId: user_id, deviceId: device.device_id)
            if !mqttmanager.isMqttConnected {
                mqttmanager.updateTopics(pub: device.publish_topic, sub: device.subscribe_topic) // publish to common topic
                
                DispatchQueue.global().async {
                    mqttmanager.configureMQTT()
                }
                
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
    
    // Helper to format the timestamp to a readable time string
    func formatTime(_ timestamp: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = formatter.date(from: timestamp) {
            formatter.dateFormat = "h a"
            return formatter.string(from: date)
        }
        return timestamp
    }
}
