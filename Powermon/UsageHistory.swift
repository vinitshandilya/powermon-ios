//
//  UsageHistory.swift
//  Powermon
//
//  Created by vshandil on 24/09/22.
//
// Heroku service sends 43800 usage datapoints (minute-wise data for a complete month)

import Foundation

class UsageHistory: ObservableObject, Identifiable {
    
    @Published var line: [DataPoint] = []
    
    func fetch() {
        let urlString = "https://pzem004t.herokuapp.com/getusagehistory"
        let url = URL(string: urlString)
        let step = 60 // Data comes for every minute. Select only 60th element from raw data to get hourly record
        
        guard url != nil else {
            return
        }
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url!) { [weak self] data, response, error in
            if error == nil && data != nil {
                // Parse JSON
                let decoder = JSONDecoder()
                do {
                    let dailyusages = try decoder.decode([DailyUsage].self, from: data!)
                    DispatchQueue.main.async {
                        self?.line.removeAll() // Clear array otherwise, data gets duplicated in chart
                        self?.line = dailyusages.reversed().enumerated().compactMap { $0.offset % step == 0 ? DataPoint(timestamp: $0.element.timestamp, usage: Double($0.element.energyUsage) ?? 0) : nil }
                    }
                } catch {
                    print("UsageHistory: Error parsing JSON!")
                }
                
            } else {
                print(error!)
            }
        }
        dataTask.resume()
    }
}
