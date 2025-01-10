//
//  Reading.swift
//  Powermon
//
//  Created by vshandil on 24/09/22.
//

import Foundation

struct MQTTReading: Hashable, Codable {
    var user_id: String = ""
    var device_id: String = ""
    var voltage: Double = 0.00
    var current: Double = 0.00
    var power: Double = 0.000
    var energy: Double = 0.000
    var frequency: Double = 0.00
    var pf: Double = 0.0
    var level: String = "unknown"
}
