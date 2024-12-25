//
//  LoginView.swift
//  Powermon
//
//  Created by vshandil on 24/12/24.
//

import SwiftUI

struct LoginView: View {
    private var nodeServer: String = "http://192.168.1.52:3000"
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var message: String = ""
    @State private var navigateToHome: Bool = false
    @State private var user_id: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Login")
                    .font(.largeTitle)
                    .bold()

                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Button("Login") {
                    loginUser()
                }
                .buttonStyle(.borderedProminent)

                NavigationLink(destination: CreateAccountView()) {
                    Text("Create a new account")
                        .foregroundColor(.blue)
                }

                NavigationLink(destination: UserHome(), isActive: $navigateToHome) {
                    EmptyView()
                }

                Text(message)
                    .foregroundColor(.red)
            }
            .padding()
        }
    }

    func loginUser() {
        guard let url = URL(string: "\(nodeServer)/login") else {
            message = "Invalid URL"
            return
        }

        // Create the request body
        let body: [String: Any] = ["username": username, "password": password]

        // Serialize the body into JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            message = "Invalid request body"
            return
        }

        // Create a custom URLSession to avoid blocking other network requests
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        // Create the URL request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        // Start the network task on a background thread
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    // Network error
                    self.message = "Error: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
                    // Invalid response or unsuccessful login
                    self.message = "Login unsuccessful"
                    return
                }

                // Try to decode the response data
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let userMessage = json["message"] as? String, userMessage == "Login successful" {
                    // Successful login
                    print("Login successful, uid: \(json["user_id"])")
                    UserDefaults.standard.set(json["user_id"], forKey: "user_id")
                    
                    self.navigateToHome = true
                } else {
                    // Response doesn't contain expected success message
                    self.message = "Login unsuccessful"
                }
            }
        }.resume()
    }

}



#Preview {
    LoginView()
}
