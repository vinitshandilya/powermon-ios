import SwiftUI

struct DeviceDetails: View {
    let device: Device
    @Environment(\.scenePhase) var scenePhase // detects application lifecycle
    @StateObject var mqttmanager = MQTTManager()
    @StateObject var chartViewModel = ReadingsViewModel()
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
                loadReadingDetailView().padding(.vertical)
                TabView(selection: $selectedTab) {
                    loadChartView(category: "byHour").tag(0)
                    loadChartView(category: "byDay").tag(1)
                    loadChartView(category: "byWeek").tag(2)
                    loadChartView(category: "byMonth").tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .indexViewStyle(.page(backgroundDisplayMode: .never))
                .onChange(of: selectedTab) { newValue in
                    print("Current page: \(newValue)")
                }
                pageIndicator()
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
                menu()
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
            chartViewModel.fetchReadings(userId: user_id, deviceId: device.device_id)
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
    
    
    func formatTime(_ timestamp: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = TimeZone.current  // Ensure it uses the local timezone
        
        if let date = formatter.date(from: timestamp) {
            formatter.dateFormat = "HH:mm a"
            //            print("raw timestamp: \(timestamp)")
            //            print("formatted time: \(formatter.string(from: date))")
            return formatter.string(from: date)
        }
        return timestamp
    }
    
    func loadReadingDetailView() -> some View {
        return HStack(alignment: .top, spacing: 10) {
            VStack {
                HStack {
                    Label(" Units", systemImage: "powermeter")
                    Spacer()
                    Text(String(mqttmanager.reading.energy)) + Text(" kWh")
                }
                HStack {
                    Label(" Voltage", systemImage: "powerplug.portrait")
                    Spacer()
                    Text(String(mqttmanager.reading.voltage)) + Text(" Volts")
                }
                HStack {
                    Label("Current", systemImage: "alternatingcurrent")
                    Spacer()
                    Text(String(mqttmanager.reading.current)) + Text(" Amp")
                }
                HStack {
                    Label(" Nominal", systemImage: "lessthanorequalto.circle")
                    Spacer()
                    Text(String(nominalUsage)) + Text(" W")
                }
            }
            
            Spacer()
            
            VStack {
                HStack {
                    Label(" Frequency", systemImage: "waveform")
                    Spacer()
                    Text(String(mqttmanager.reading.frequency)) + Text(" Hz")
                }
                HStack {
                    Label("Power Factor", systemImage: "angle")
                    Spacer()
                    Text(String(mqttmanager.reading.pf))
                }
                HStack {
                    Label(" Usage", systemImage: "leaf.circle")
                    Spacer()
                    Text(String(mqttmanager.reading.level))
                }
                HStack {
                    Label(" Alarm", systemImage: "greaterthanorequalto.circle")
                    Spacer()
                    Text(String(maximumUsage)) + Text(" W")
                }
            }
            
        }
        .font(.footnote)
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    func loadChartView(category: String) -> some View {
        var usages: [Usage] = []
        var chartTitle: String = ""
        
        switch category {
        case "byHour":
            usages = chartViewModel.hourlyReadings
            chartTitle = "Units Used Per Hour"
        case "byDay":
            usages = chartViewModel.dailyReadings
            chartTitle = "Daily Usage"
        case "byWeek":
            usages = chartViewModel.weeklyReadings
            chartTitle = "Weekly Usage"
        case "byMonth":
            usages = chartViewModel.monthlyReadings
            chartTitle = "Monthly Usage"
        default:
            usages = []
            chartTitle = "Unknown Category"
        }
        
        let view = VStack(alignment: .center, spacing: 20) { // root chart area card
            
            Text(chartTitle)
                .font(.body)
                .fontWeight(.bold)
                .foregroundStyle(.gray)
                .padding()
            
            if !chartViewModel.isDataLoaded {
                Text("Loading...")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else if usages.isEmpty {
                Text("No data found.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else {
                CustomBarChart(usages: Array(usages.suffix(11)))
            }
        }
            .frame(width: UIScreen.main.bounds.width * 0.9, height: 330)
            .background(
                RoundedRectangle(cornerRadius: 10) // Rounded rectangle as background
                    .fill(Color("CardBg")) // Card color
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5) // Add shadow
            )
            .padding()
            
        return view
    }
    
    func pageIndicator() -> some View {
        return HStack(alignment: .center, spacing: 10) {
            selectedTab == 0 ? Text("●").foregroundColor(.green) : Text("●").foregroundColor(.gray)
            selectedTab == 1 ? Text("●").foregroundColor(.green) : Text("●").foregroundColor(.gray)
            selectedTab == 2 ? Text("●").foregroundColor(.green) : Text("●").foregroundColor(.gray)
            selectedTab == 3 ? Text("●").foregroundColor(.green) : Text("●").foregroundColor(.gray)
        }
        .font(.footnote)
    }
    
    func menu() -> some View {
        return Menu {
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
