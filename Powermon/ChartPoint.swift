struct ChartPoint: Identifiable, Codable {
    var id: String
    var user_id: String
    var device_id: String
    var power: Int
    var timestamp: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case user_id, device_id, power, timestamp
    }
}
