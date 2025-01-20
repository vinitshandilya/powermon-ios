import SwiftUI

struct LoginView: View {
    @StateObject private var apiService = UserApiService()
    
    @State private var loginInput: String = "" // The input field for username/email
    @State private var password: String = ""
    @State private var user_id: String = ""

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("Login")
                    .font(.title)
                    .bold()

                TextField("Username or Email", text: $loginInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding(.horizontal)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Button("Login") {
                    apiService.loginUser(loginInput: loginInput, password: password)
                }
                .buttonStyle(.borderedProminent)
                .disabled(
                    loginInput.isEmpty || password.isEmpty
                )
                
                if(apiService.waitingForServerResponse) {
                    HStack {
                        ProgressView().scaleEffect(0.8)
                        Text("Logging you in. Please wait...")
                    }
                    .foregroundColor(.gray)
                }

                if let message = apiService.message {
                    Text(message).foregroundColor(apiService.isError ? .red : .primary)
                }
            }
            .padding()
            
            Spacer()
            
            HStack(alignment: .center, spacing: 4) {
                Text("Don't have an account?")
                    .font(.caption)
                Text("Create new")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .onTapGesture {
                        navigateToCreateAccountPage()
                    }
            }
            .frame(maxWidth: .infinity, alignment: .bottom)
            
        }
        .onChange(of: apiService.message) { newMessage in
            if newMessage == "Login successful" {
                navigateToUserHome()
            }
        }
        
    }

    func navigateToUserHome() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            print("Failed to get the key window")
            return
        }
        window.rootViewController = UIHostingController(rootView: UserHome())
        window.makeKeyAndVisible()
    }
    
    func navigateToCreateAccountPage() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            print("Failed to get the key window")
            return
        }
        window.rootViewController = UIHostingController(rootView: CreateAccountView())
        window.makeKeyAndVisible()
    }
}
