import SwiftUI

struct DeviceDetails: View {
    let device: Device
    @StateObject var mqttmanager: MQTTManager
    @EnvironmentObject var navigationManager: NavigationManager
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.dismiss) private var dismiss
    @StateObject var energyChartViewModel = EnergyChartViewModel()
    @State private var user_id: String = UserDefaults.standard.string(forKey: "user_id") ?? ""
    @State private var isResetDialogShowing: Bool = false
    @State private var nominalUsage: Double = UserDefaults.standard.double(forKey: "nominalUsage") == 0 ? 500 : UserDefaults.standard.double(forKey: "nominalUsage")
    @State private var maximumUsage: Double = UserDefaults.standard.double(forKey: "maximumUsage") == 0 ? 1000 : UserDefaults.standard.double(forKey: "maximumUsage")
    @State private var isLevelSetDialogShowing = false
    @State private var showLineChart = false
    @StateObject private var snackBarManager = SnackBarManager()
    @State private var selectedChart = "Hour"
    
    var isRightDevice: Bool {
        device.device_id == mqttmanager.reading.device_id
    }
    
    
    var body: some View {
        ZStack { // To show snackbar overlay
            VStack(alignment: .center, spacing: 0) {
                RingWidgetTable(device_id: device.device_id,
                                reading: mqttmanager.reading,
                                minValue: nominalUsage,
                                maxValue: maximumUsage,
                                isMqttConnected: mqttmanager.isMqttConnected)
                
                ChartSelectorTabs(selectedChart: $selectedChart)
                
                
                if selectedChart == "Hour" {
                    if showLineChart {
                        ScrollableLineChartView(usages: energyChartViewModel.hourlyReadings)
                    } else {
                        loadChartView(category: "byHour")
                    }
                }
                
                if selectedChart == "Day" {
                    if showLineChart {
                        ScrollableLineChartView(usages: energyChartViewModel.dailyReadings)
                    } else {
                        loadChartView(category: "byDay")
                    }
                }
                
                if selectedChart == "Week" {
                    if showLineChart {
                        ScrollableLineChartView(usages: energyChartViewModel.weeklyReadings)
                    } else {
                        loadChartView(category: "byWeek")
                    }
                }
                
                if selectedChart == "Month" {
                    if showLineChart {
                        ScrollableLineChartView(usages: energyChartViewModel.monthlyReadings)
                    } else {
                        loadChartView(category: "byMonth")
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            
            SnackBarView(manager: snackBarManager)
        }
        .confirmationDialog("Are you sure?", isPresented: $isResetDialogShowing) {
            Button("Reset usage?", role: .destructive) { mqttmanager.publishMessage(topic: device.subscribe_topic, message: "1")}
        }
        message: {
            Text("Usage will be reset. You cannot undo this")
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
            // Page title and notification badge
            ToolbarItem(placement: .principal) {
                Text(device.device_name).font(.headline)
            }
            // ... menu
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
                    mqttmanager.publishMessage(topic: device.subscribe_topic, message: message)
                }
            )
        }
        .onAppear {
            print("DeviceDetails: onAppear")
            print("device publishing on topic: \(device.publish_topic)")
            print("device subscribed on topic: \(device.subscribe_topic)")
            // Load usage chart only when coming from HomeTab!
            print("last visited view: \(navigationManager.lastVisitedView)")
            DispatchQueue.global().async {
                energyChartViewModel.fetchReadings(userId: user_id, deviceId: device.device_id)
            }
            navigationManager.lastVisitedView = "DeviceDetails"
        }
        .onDisappear() {
            print("DeviceDetails: onDisappear")
        }
        .onChange(of: scenePhase) { newPhase in
            print("DeviceDetails: \(newPhase)")
            if newPhase == .active {
                
            }
            if newPhase == .inactive {
                
            }
        }
        .onChange(of: mqttmanager.publishedOK) { itstrue in
            if itstrue {
                snackBarManager.show(message: "Message sent successfully")
                mqttmanager.publishedOK = false
            }
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    
    func loadChartView(category: String) -> some View {
        var usages: [EnergyReading] = []
        var chartTitle: String = ""
        
        switch category {
        case "byHour":
            usages = energyChartViewModel.hourlyReadings
            chartTitle = "Units By Hour"
        case "byDay":
            usages = energyChartViewModel.dailyReadings
            chartTitle = "Daily Usage"
        case "byWeek":
            usages = energyChartViewModel.weeklyReadings
            chartTitle = "Weekly Usage"
        case "byMonth":
            usages = energyChartViewModel.monthlyReadings
            chartTitle = "Monthly Usage"
        default:
            usages = []
            chartTitle = "Getting past usage"
        }
        
        let view = VStack(alignment: .center, spacing: 0) { // root chart area card
            
            if !energyChartViewModel.isDataLoaded {
                Spacer()
                ProgressView().scaleEffect(0.8)
                Spacer()
            } else {
//                CustomBarChart(usages: Array(usages.suffix(11)),
//                               category: category,
//                               chartTitle: chartTitle)
               ScrollableBarChart(usages: usages, category: category, chartTitle: chartTitle)
            }
        }
            .frame(width: UIScreen.main.bounds.width)
        
        return view
    }
    
    
    func menu() -> some View {
        return Menu {
            
            Button(action: {
                showLineChart.toggle()
            }) {
                showLineChart ? Label("Show Bar Chart", systemImage: "chart.bar.xaxis") : Label("Show Line Chart", systemImage: "chart.line.uptrend.xyaxis.circle")
            }
            
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
            .disabled(!isRightDevice)
            
            Button(role: .destructive, action: {
                isResetDialogShowing = true
            }) {
                Label("Reset kWh", systemImage: "arrow.clockwise.circle")
            }
            .disabled(!isRightDevice)
            
        } label: {
            Image(systemName: "ellipsis")
                .imageScale(.large)
                .foregroundColor(.gray)
                .padding(10)
                .contentShape(Rectangle())
        }
    }
    
}
