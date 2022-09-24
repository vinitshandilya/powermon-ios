//
//  UsageHistory.swift
//  Powermon
//
//  Created by vshandil on 24/09/22.
//

import Foundation

class UsageHistory: ObservableObject, Identifiable {
    
    @Published var dailyusage: [DailyUsage] = []

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
                    print(dailyusage)
                    DispatchQueue.main.async {
                        self?.dailyusage = dailyusage
                    }
                    
                } catch {
                    print("Error parsing JSON!")
                }
                
            } else {
                print(error!)
            }
        }
        dataTask.resume()
    }
}
