import Foundation

struct Config {
    static let nodeServer: String = "https://wattwise-k1f5.onrender.com"
    static let espServer: String = "http://nodemcu.local"
    static let broker: String = "broker.hivemq.com" // test.mosquitto.org
    static let brokerPort: String = "1883"
    static let mqttuser: String = ""
    static let mqttpassword: String = ""
    static let globalTopic: String = "wattwise/readings/all"
}
