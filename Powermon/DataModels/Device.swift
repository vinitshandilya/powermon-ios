//
//  Device.swift
//  Powermon
//
//  Created by vshandil on 26/12/24.
//

import Foundation

struct Device: Identifiable, Decodable, Encodable, Hashable {
    let id = UUID()
    let device_name: String
    let device_id: String
    let subscribe_topic: String
    let publish_topic: String
    let lower_limit: Int
    let upper_limit: Int
}
