//
//  UsageHistory.swift
//  Powermon
//
//  Created by vshandil on 24/09/22.
//

import Foundation

class UsageHistory: ObservableObject, Identifiable {
    
    @Published var dailyusages: [DailyUsage] = []
    @Published var line: [DataPoint] = []

    func fetch() {
        let urlString = "https://pzem004t.herokuapp.com/getusagehistory"
        let url = URL(string: urlString)
        
        guard url != nil else {
            return
        }
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url!) { [weak self] data, response, error in
            if error == nil && data != nil {
                // Parse JSON
                let decoder = JSONDecoder()
                do {
                    let dailyusage = try decoder.decode([DailyUsage].self, from: data!)
                    //print(dailyusage)
                    DispatchQueue.main.async {
                        self?.dailyusages = dailyusage
                        self?.line.removeAll() // Clear array otherwise, data gets duplicated in chart
                        // This also needs to run on UI thread.
                    }
                    
                    // Fill in the line data from dailyusage array
                    for i in dailyusage.reversed() {
                        DispatchQueue.main.async {
                            //print(DataPoint(timestamp: i.timestamp, usage: Double(i.energyUsage) ?? 0))
                            self?.line.append(DataPoint(timestamp: i.timestamp, usage: Double(i.energyUsage) ?? 0))
                        }
                        
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
