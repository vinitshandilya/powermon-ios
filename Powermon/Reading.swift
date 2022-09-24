//
//  Reading.swift
//  Powermon
//
//  Created by vshandil on 24/09/22.
//

import Foundation

struct Reading: Hashable, Codable {
    var Voltage: String = ""
    var Current: String = ""
    var Power: String = ""
    var Energy: String = ""
    var Frequency: String = ""
    var PF: String = ""
}
