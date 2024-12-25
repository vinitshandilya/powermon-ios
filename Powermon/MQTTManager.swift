import CocoaMQTT
import Foundation

class MQTTManager: CocoaMQTTDelegate, ObservableObject {
    @Published var reading: Reading = Reading()
    @Published var isMqttConnected: Bool = false
    let clientID = "iphone12_\(UUID().uuidString.prefix(6))"
    let host = UserDefaults.standard.string(forKey: "broker") ?? "broker.hivemq.com"
    let savedPort = UserDefaults.standard.integer(forKey: "port")
    let username = UserDefaults.standard.string(forKey: "username") ?? ""
    let mqttpassword = UserDefaults.standard.string(forKey: "mqttpassword") ?? ""
    var publishtopic: String = ""
    var subscribetopic: String = ""
    
    func updateTopics(pub: String, sub: String) {
        self.publishtopic = pub
        self.subscribetopic = sub
    }
    
    func configureMQTT() {
        let port: UInt16 = savedPort == 0 ? 1883 : UInt16(savedPort)
        staticMQTT.mqttClient = CocoaMQTT(clientID: clientID, host: host, port: port)
        staticMQTT.mqttClient.username = username
        staticMQTT.mqttClient.password = mqttpassword
        staticMQTT.mqttClient.keepAlive = 60
        staticMQTT.mqttClient.delegate = self
        let _ = staticMQTT.mqttClient.connect()
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("Mqtt didConnectAck", ack.description)
        
        if ack.description == "accept" {
            mqtt.subscribe(publishtopic)
            isMqttConnected = true
        } else {
            print("broker connection failed!")
            isMqttConnected = false
        }
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("Message published on topic \(message.topic) with payload \(message.string!)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        print("Received message on topic: \(message.topic) with payload: \(String(describing: message.string))")
        let readingData = message.string ?? ""
        
        guard let jsonData = readingData.data(using: .utf8) else {
            print("Failed to convert message string to data: \(String(describing: message.string))")
            return
        }
        
        do {
            reading = try JSONDecoder().decode(Reading.self, from: jsonData)
        } catch {
            print("Failed to decode message into Reading: \(String(describing: message.string))")
            return
        }
    }

    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
            
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        
    }
    
    struct staticMQTT {
        static var mqttClient: CocoaMQTT!
    }
    
    func sendMessage(topic:String, message:String){
        print("message to publish from mqttmanager: \(message)")
        staticMQTT.mqttClient.publish(topic, withString: message)
    }
    
}
