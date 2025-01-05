import SwiftUI

struct Usage: Codable, Identifiable {
    let id = UUID()
    let timestamp: String
    let power: Int
}

struct UsageHistory: Codable {
    let hourly_readings: [Usage]
    let daily_readings: [Usage]
    let weekly_readings: [Usage]
    let monthly_readings: [Usage]
}

class ReadingsViewModel: ObservableObject {
    @Published var hourlyReadings: [Usage] = []
    @Published var dailyReadings: [Usage] = []
    @Published var weeklyReadings: [Usage] = []
    @Published var monthlyReadings: [Usage] = []
    @Published var isDataLoaded: Bool = false
    
    func fetchReadings(userId: String, deviceId: String) {
        self.isDataLoaded = false;
        guard let url = URL(string: "\(Config.nodeServer)/getReadings?user_id=\(userId)&device_id=\(deviceId)") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(UsageHistory.self, from: data)
                    DispatchQueue.main.async {
                        self.isDataLoaded = true;
                        self.hourlyReadings = response.hourly_readings
                        self.dailyReadings = response.daily_readings
                        self.weeklyReadings = response.weekly_readings
                        self.monthlyReadings = response.monthly_readings
                    }
                } catch {
                    self.isDataLoaded = false;
                    print("Error decoding response: \(error)")
                }
            }
        }.resume()
    }
}
