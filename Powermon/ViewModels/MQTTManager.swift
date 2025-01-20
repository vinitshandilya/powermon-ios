import CocoaMQTT
import Foundation

class MQTTManager: CocoaMQTTDelegate, ObservableObject {
    @Published var reading: MQTTReading = MQTTReading()
    @Published var isMqttConnected: Bool = false
    @Published var isMqttSubscribed: Bool = false
    @Published var hasReceivedMessage: Bool = false
    @Published var publishedOK: Bool = false
    let clientID = "iphone12_\(UUID().uuidString.prefix(6))"
    let host = Config.broker
    let port = Config.brokerPort
    let mqttuser = Config.mqttuser
    let mqttpassword = Config.mqttpassword
    
    func connectToMqtt() { // connect to broker
        DispatchQueue.main.async {
            self.isMqttConnected = false
            self.isMqttSubscribed = false
            self.hasReceivedMessage = false
        }
        staticMQTT.mqttClient = CocoaMQTT(clientID: clientID, host: host, port: UInt16(port)!) // TODO: Do not force unwrap!
        if (!mqttuser.isEmpty && !mqttpassword.isEmpty) {
            staticMQTT.mqttClient.username = mqttuser
            staticMQTT.mqttClient.password = mqttpassword
        }
        staticMQTT.mqttClient.keepAlive = 60
        staticMQTT.mqttClient.delegate = self
        let _ = staticMQTT.mqttClient.connect()
    }
    
    func subscribeToTopic(subscribetopic: String) {
        staticMQTT.mqttClient.subscribe(subscribetopic)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) { // mqtt connection callback
        print("mqtt connection", ack.description)
        if ack.description == "accept" {
            mqtt.subscribe(Config.globalTopic)
            DispatchQueue.main.async {
                self.isMqttConnected = true
            }
        } else {
            DispatchQueue.main.async {
                self.isMqttConnected = false
            }
        }
    }
    
    func disconnectMQTT() { // disconnect from broker
        staticMQTT.mqttClient.disconnect()
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) { // mqtt disconnection callback
        print("mqtt disconnected, \(err?.localizedDescription ?? "")")
        DispatchQueue.main.async {
            self.isMqttConnected = false
            self.isMqttSubscribed = false
        }
    }
    
    func publishMessage(topic:String, message:String){ // publish message
        print("message to publish from mqttmanager: \(message)")
        staticMQTT.mqttClient.publish(topic, withString: message)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) { // message published callback
        print("Message published on topic \(message.topic) with payload \(message.string!)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) { // message published callback status
        print("mqtt didPublishAck", id.description)
        publishedOK = true
        
        // TODO: We need to ack command submission too
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) { // message received
        // print("Received message on topic: \(message.topic) with payload: \(String(describing: message.string))")
        
        DispatchQueue.main.async {
            self.hasReceivedMessage = true
        }
        
        let readingData = message.string ?? ""
        
        guard let jsonData = readingData.data(using: .utf8) else {
            print("Failed to convert message string to data: \(String(describing: message.string))")
            return
        }
        
        do {
            // listens to all devices' readings!! :( // TODO: Is it safe??
            reading = try JSONDecoder().decode(MQTTReading.self, from: jsonData)
            // print("userid: \(reading.user_id), deviceid: \(reading.device_id)")
        } catch {
            print("Failed to decode message into Reading: \(String(describing: message.string))")
            return
        }
    }

    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) { // mqtt subscribed callback
        print("mqtt didSubscribeTopics, \(success.description)")
        DispatchQueue.main.async {
            self.isMqttSubscribed = true
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) { // mqtt unsubscribe callback
        print("mqtt didUnsubscribeTopics, \(topics.description)")
        DispatchQueue.main.async {
            self.isMqttSubscribed = true
        }
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        
    }
    
    struct staticMQTT {
        static var mqttClient: CocoaMQTT!
    }
    
}
