import SwiftUI

struct UserHome: View {
    @State private var selectedTab: String = "Home"
    @StateObject private var navigationManager = NavigationManager()
    @StateObject var mqttmanager = MQTTManager()
    @State private var showHamburgerMenu: Bool = false
    @State private var username: String = UserDefaults.standard.string(forKey: "username") ?? ""
    
    // Container view for: HomeTab, AnalyticsTab, etc.
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                switch selectedTab {
                case "Home":
                    HomeTab(mqttmanager: mqttmanager).environmentObject(navigationManager)
                case "Automations":
                    AutomationsTab().environmentObject(navigationManager)
                case "Analytics":
                    AnalyticsTab().environmentObject(navigationManager)
                case "Settings":
                    AppSettingsTab().environmentObject(navigationManager)
                default:
                    Text("default")
                }
                
                Spacer()
                
                TabBar(selectedTab: $selectedTab)
                    .frame(maxWidth: .infinity, alignment: .bottom)
                    .padding(.bottom, 15)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.bottom)
            .sheet(isPresented: $showHamburgerMenu) {
                HamburgerMenuView(onLogout: {
                    logoutUser()
                    showHamburgerMenu = false
                })
                .presentationDetents([.fraction(0.2)])
                .presentationDragIndicator(.visible)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        showHamburgerMenu.toggle()
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(Color("NavbarItemsColor"))
                            .font(.headline)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    HStack(alignment: .center, spacing: 5) {
                        selectedTab == "Home" ? Text("\(Config.appDisplayName)") : Text("\(selectedTab)")
                        NotificationBadge(active: true)
                    }
                    .font(.headline)
                    .foregroundColor(Color("NavbarItemsColor"))
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: MeterSettings().environmentObject(navigationManager)) {
                        Image(systemName: "plus")
                            .foregroundColor(Color("NavbarItemsColor"))
                            .font(.headline)
                    }
                }
            }
        }
    }
    
    private func logoutUser() {
        // TODO: cancel all network tasks to prevent unexpected response when logged in as a different user, while old network call is still waiting for a server response.
        saveDeviceArrayLocally(devices: []) // clear devices from local storage
        UserDefaults.standard.set("", forKey: "user_id") // clear saved user id
        UserDefaults.standard.set("", forKey: "username") // clear saved username
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


