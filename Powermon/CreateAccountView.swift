//
//  CreateAccountView.swift
//  Powermon
//
//  Created by vshandil on 24/12/24.
//

import SwiftUI

struct CreateAccountView: View {
    private var nodeServer: String = "https://wattwise-k1f5.onrender.com"
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var message: String = ""
    @State private var waitingForServerResponse: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account")
                .font(.largeTitle)
                .bold()

            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button("Create Account") {
                createAccount()
            }
            .buttonStyle(.borderedProminent)
            
            if(waitingForServerResponse) {
                HStack {
                    ProgressView().scaleEffect(0.8)
                    Text("Creating your account. Please wait...")
                }
                .foregroundColor(.gray)
            }



            Text(message)
                .foregroundColor(.red)
        }
        .padding()
    }

    func createAccount() {
        waitingForServerResponse = true
        guard let url = URL(string: "\(nodeServer)/create-account") else {
            message = "Invalid URL"
            waitingForServerResponse = false
            return
        }

        let body: [String: Any] = ["username": username, "password": password]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            message = "Invalid request body"
            waitingForServerResponse = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    message = "Error: \(error.localizedDescription)"
                    waitingForServerResponse = false
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    message = "Failed to create account"
                    waitingForServerResponse = false
                    return
                }

                message = "Account created successfully!"
                waitingForServerResponse = false
                navigateToLoginPage()
            }
        }.resume()
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

#Preview {
    CreateAccountView()
}
