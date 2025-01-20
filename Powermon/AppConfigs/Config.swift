import Foundation

struct Config {
    static let appDisplayName: String = "Wattwise"
    static let nodeServer: String = "https://wattwise-k1f5.onrender.com"
//    static let nodeServer: String = "http://localhost:3000"
    static let espServer: String = "http://nodemcu.local"
//    static let broker: String = "broker.hivemq.com"
    static let broker: String = "test.mosquitto.org"
    static let brokerPort: String = "1883"
    static let mqttuser: String = ""
    static let mqttpassword: String = ""
    static let globalTopic: String = "wattwise/readings/all"
}
