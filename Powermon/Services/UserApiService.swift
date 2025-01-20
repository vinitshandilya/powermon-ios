import Foundation

class UserApiService: ObservableObject {
    @Published var message: String? = nil
    @Published var isError: Bool = false
    @Published var waitingForServerResponse: Bool = false
    
    private var isEmail: Bool = false
    
    func createAccount(username: String, email: String, password: String) {
        self.waitingForServerResponse = true
        guard let url = URL(string: "\(Config.nodeServer)/create-account") else {
            self.message = "Invalid URL"
            self.isError = true
            self.waitingForServerResponse = false
            return
        }

        let body: [String: Any] = [
            "username": username,
            "email": email,
            "password": password]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            self.message = "Invalid request body"
            self.isError = true;
            self.waitingForServerResponse = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.message = "Error: \(error.localizedDescription)"
                    self.isError = true
                    self.waitingForServerResponse = false
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    if let data = data {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                               let errorMessage = json["message"] as? String {
                                self.message = errorMessage
                            } else {
                                self.message = "Account creation failed: An unknown error occurred" // Fallback if no message key
                            }
                        } catch {
                            self.message = "Account creation failed: An unknown error occurred"
                        }
                    } else {
                        self.message = "Account creation failed: No response from server"
                    }
                    self.isError = true;
                    self.waitingForServerResponse = false
                    return
                }
                
                self.message = "Account created successfully!"
                self.isError = false;
                self.waitingForServerResponse = false
            }
        }.resume()
    }
    
    func loginUser(loginInput: String, password: String) {
        self.waitingForServerResponse = true
        self.message = ""
        guard let url = URL(string: "\(Config.nodeServer)/login") else {
            self.message = "Invalid URL"
            self.isError = true
            return
        }

        // Determine if the input is a valid email
        if isValidEmail(loginInput) {
            isEmail = true
        } else {
            isEmail = false
        }

        // Prepare the body based on whether it's an email or username
        var body: [String: Any] = ["password": password]
        
        if isEmail {
            // If the input is an email, send email in the "email" key
            body["email"] = loginInput
        } else {
            // Otherwise, send username in the "username" key
            body["username"] = loginInput
        }

        // Serialize the body into JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            self.message = "Invalid request body"
            self.isError = true
            self.waitingForServerResponse = false
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
                    self.waitingForServerResponse = false
                    self.isError = true
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
                    self.isError = true
                    if let data = data {
                        do {
                            // Try to decode the response as JSON to get the error message
                            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                               let errorMessage = json["message"] as? String {
                                self.message = errorMessage // Show the server's error message
                            } else {
                                self.message = "Login failed: An unknown error occurred" // Fallback if no message key
                            }
                        } catch {
                            self.message = "Login failed: An unknown error occurred"
                        }
                    } else {
                        self.message = "Login failed: No response from server"
                    }
                    self.waitingForServerResponse = false
                    return
                }

                // Decode the response data into a User model
                if let decodedResponse = try? JSONDecoder().decode(User.self, from: data) {
                    // Successful login
                    UserDefaults.standard.set(decodedResponse.user_id, forKey: "user_id")
                    UserDefaults.standard.set(decodedResponse.username, forKey: "username")
                    UserDefaults.standard.set(decodedResponse.email, forKey: "email")
                    self.waitingForServerResponse = false
                    self.isError = false
                    self.message = "Login successful"
                } else {
                    // Response doesn't match the expected structure
                    self.message = "Login unsuccessful"
                    self.isError = true
                    self.waitingForServerResponse = false
                }
            }
        }.resume()
    }
    
    func deleteAccount(user_id: String) {
        self.waitingForServerResponse = true
        guard let url = URL(string: "\(Config.nodeServer)/delete-account") else {
            self.message = "Invalid URL"
            self.isError = true
            self.waitingForServerResponse = false
            return
        }
        
        // Create the request body
        let body: [String: Any] = ["user_id": user_id]
        
        // Serialize the body into JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            self.message = "Invalid request body"
            self.isError = true
            self.waitingForServerResponse = false
            return
        }
        
        // Create the URL request
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Start the network task on a background thread
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    // Handle network error
                    self.message = "Error: \(error.localizedDescription)"
                    self.isError = true
                    self.waitingForServerResponse = false
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
                    // Handle invalid response or unsuccessful deletion
                    self.message = "Failed to delete account"
                    self.isError = true
                    self.waitingForServerResponse = false
                    return
                }
                
                // Try to decode the response data
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let userMessage = json["message"] as? String, userMessage == "User account deleted successfully" {
                    self.message = "Account successfully deleted"
                    self.isError = false
                } else {
                    self.message = "Failed to delete account"
                    self.isError = true
                }
                
                self.waitingForServerResponse = false
            }
        }.resume()
    }
    
    // Function to check if the input is a valid email
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
}
