import SwiftUI

struct CreateAccountView: View {
    @StateObject private var apiService = UserApiService()
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var conf_password: String = ""
    @State private var email: String = ""
    @State private var message: String = ""

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer()
            VStack(spacing: 20) {
                Text("Create Account")
                    .font(.title)
                    .bold()

                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding(.horizontal)
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textContentType(.emailAddress)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                SecureField("Confirm Password", text: $conf_password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Button("Create Account") {
                    apiService.createAccount(username: username, email: email, password: password)
                }
                .buttonStyle(.borderedProminent)
                .disabled(
                    username.isEmpty || password.isEmpty || email.isEmpty || conf_password.isEmpty || password != conf_password
                )
                
                if(apiService.waitingForServerResponse) {
                    HStack {
                        ProgressView().scaleEffect(0.8)
                        Text("Creating your account. Please wait...")
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
                Text("Already have an account?")
                    .font(.caption)
                Text("Login")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .onTapGesture {
                        navigateToLoginPage()
                    }
            }
            .frame(maxWidth: .infinity, alignment: .bottom)
            
        }
        
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
}

//#Preview {
//    CreateAccountView()
//}
