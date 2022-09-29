//
//  DataPoint.swift
//  Powermon
//
//  Created by vshandil on 27/09/22.
//

import Foundation

struct DataPoint: Identifiable {
    let id = UUID()
    let timestamp: String
    let usage: Double
    
    init(timestamp: String, usage: Double) {
        self.timestamp = timestamp
        self.usage = usage
    }
}
