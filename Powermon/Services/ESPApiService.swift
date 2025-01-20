import Foundation

class ESPApiService: ObservableObject {
    @Published var isSearchingESP = false
    @Published var espSearchTimedOut = false
    @Published var isESPReachable = false
    @Published var espServerResponse: String = ""
    @Published var espServerError: String = ""
    @Published var isSubmitting = false
    @Published var submitMessage: SubmitMessage? = nil

    func testESPReachability() {
        // Reset state
        DispatchQueue.main.async {
            self.isSearchingESP = true
            self.espSearchTimedOut = false
            self.isESPReachable = false
            self.espServerResponse = ""
            self.espServerError = ""
        }

        guard let url = URL(string: Config.espServer.appending("/knock")) else {
            DispatchQueue.main.async {
                self.isESPReachable = false
                self.isSearchingESP = false
                self.espServerError = "Invalid URL"
            }
            return
        }

        // Create a URLSession configuration with a timeout
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 10
        let session = URLSession(configuration: config)

        // Create a URL session data task
        let task = session.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                if let error = error {
                    // Handle error (e.g., no network, unreachable, or timeout)
                    self.isESPReachable = false
                    self.isSearchingESP = false
                    if (error as NSError).code == NSURLErrorTimedOut {
                        self.espSearchTimedOut = true
                        self.espServerError = "Request timed out"
                    } else {
                        self.espServerError = error.localizedDescription
                    }
                    return
                }

                // Check the HTTP response code
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        self.isESPReachable = true
                        self.isSearchingESP = false
                        self.espSearchTimedOut = false

                        if let responseData = data, let responseText = String(data: responseData, encoding: .utf8) {
                            self.espServerResponse = responseText
                        } else {
                            self.espServerResponse = "Unable to decode response text."
                        }
                    } else {
                        self.isESPReachable = false
                        self.isSearchingESP = false
                        self.espServerError = "HTTP Error: \(httpResponse.statusCode)"
                    }
                }
            }
        }
        task.resume()
    }
    
    func saveSettingsOnMeter(ssid: String, password: String, broker: String, port: String, username: String, mqttpassword: String, subscribetopic: String, publishtopic: String, user_id: String, device_id: String, autoreconnect: Bool) {
        
        isSubmitting = true
        submitMessage = nil
        
        print("saving subscribe topic: \(subscribetopic)")
        print("saving publish topic: \(publishtopic)")
        
        var parameters: [String: String] = [
            "ssid": ssid,
            "password": password,
            "broker": broker,
            "port": port,
            "username": username,
            "mqttpassword": mqttpassword,
            "subscribetopic": subscribetopic,
            "publishtopic": publishtopic,
            "user_id": user_id,
            "device_id": device_id
        ]
        if autoreconnect {
            parameters["autoreconnect"] = "true"
        }
        
        // Send settings data to ESP
        guard let url = URL(string: Config.espServer.appending("/setconfig")) else {
            submitMessage = SubmitMessage(text: "Invalid server URL.")
            isSubmitting = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("close", forHTTPHeaderField: "Connection") // Ensure connection closure
        // request.timeoutInterval = 10 // Adjust timeout interval
        
        let body = parameters.compactMap { key, value in
            value.isEmpty ? nil : "\(key)=\(value)"
        }.joined(separator: "&")
        request.httpBody = body.data(using: .utf8)
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isSubmitting = false
                if let error = error {
                    self.submitMessage = SubmitMessage(text: "Error: \(error.localizedDescription)")
                    return
                }
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    self.submitMessage = SubmitMessage(text: "Configuration submitted successfully.")
                    print("restarting mqtt client on ios")
                } else {
                    self.submitMessage = SubmitMessage(text: "Failed to submit configuration.")
                }
            }
        }.resume()

    }
}

struct SubmitMessage: Identifiable {
    let id = UUID()
    let text: String
}

