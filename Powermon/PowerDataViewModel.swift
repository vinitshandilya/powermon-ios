import SwiftUI

class PowerDataViewModel: ObservableObject {
    @Published var chartpoints: [ChartPoint] = []
    
    func fetchPowerData(userId: String, deviceId: String) {
        let urlString = "\(Config.nodeServer)/get-hourly-reading?user_id=\(userId)&device_id=\(deviceId)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode([ChartPoint].self, from: data)
                    DispatchQueue.main.async {
                        self.chartpoints = decodedData
                    }
                } catch {
                    print("Error decoding data: \(error)")
                }
            }
        }.resume()
    }
}

