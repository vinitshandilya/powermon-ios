import SwiftUI

struct EnergyReading: Codable, Identifiable {
    let id = UUID()
    let timestamp: String
    let power: Int
}

struct EnergyUsageData: Codable {
    let hourly_readings: [EnergyReading]
    let daily_readings: [EnergyReading]
    let weekly_readings: [EnergyReading]
    let monthly_readings: [EnergyReading]
}


