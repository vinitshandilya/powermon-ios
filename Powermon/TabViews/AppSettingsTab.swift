import SwiftUI

struct AppSettingsTab: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject private var apiService = UserApiService()
    @State private var user_id: String = UserDefaults.standard.string(forKey: "user_id") ?? ""
    @State private var message: String = ""
    @State private var waitingForServerResponse: Bool = false
    
    var body: some View {
        VStack {
            List {
                Text("Delete account")
                    .foregroundColor(.red)
                    .onTapGesture {
                        apiService.deleteAccount(user_id: user_id)
                    }
            }
            
            if(apiService.waitingForServerResponse) {
                HStack {
                    ProgressView().scaleEffect(0.8)
                    Text("Deleting account. Please wait...")
                }
                .foregroundColor(.gray)
            }
            if let message = apiService.message {
                Text(message).foregroundColor(apiService.isError ? .red : .primary)
            }
            
        }
        .onAppear {
            navigationManager.lastVisitedView = "AppSettingsTab"
        }
        .onChange(of: apiService.message) { newMessage in
            if newMessage == "Account successfully deleted" {
                logoutUser()
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
