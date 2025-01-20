import SwiftUI

class EnergyChartViewModel: ObservableObject {
    @Published var hourlyReadings: [EnergyReading] = []
    @Published var dailyReadings: [EnergyReading] = []
    @Published var weeklyReadings: [EnergyReading] = []
    @Published var monthlyReadings: [EnergyReading] = []
    @Published var isDataLoaded: Bool = false
    
    func fetchReadings(userId: String, deviceId: String) {
        DispatchQueue.main.async {
            self.isDataLoaded = false
        }
        
        guard let url = URL(string: "\(Config.nodeServer)/getReadings?user_id=\(userId)&device_id=\(deviceId)") else {
            print("Error: Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    self.isDataLoaded = true
                }
                print("Error: No data received from the server.")
                
                return
            }
            
            do {
                let decoder = JSONDecoder()
                
                // Attempt to decode the successful response
                if let response = try? decoder.decode(EnergyUsageData.self, from: data) {
                    DispatchQueue.main.async {
                        self.isDataLoaded = true
                        self.hourlyReadings = response.hourly_readings
                        self.dailyReadings = response.daily_readings
                        self.weeklyReadings = response.weekly_readings
                        self.monthlyReadings = response.monthly_readings
                    }
                } else {
                    // Attempt to decode the error response
                    let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.isDataLoaded = true
                    }
                    print("Server Error: \(errorResponse.error)")
                    
                }
            } catch {
                DispatchQueue.main.async {
                    self.isDataLoaded = true
                }
                print("Error decoding response: \(error)")
            }
        }.resume()
    }

}

struct ErrorResponse: Decodable {
    let error: String
}
