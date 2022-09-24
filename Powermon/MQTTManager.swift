//
//  MQTTManager.swift
//  Powermon
//
//  Created by vshandil on 24/09/22.
//

import CocoaMQTT
import Foundation

class MQTTManager: CocoaMQTTDelegate, ObservableObject {
    var reading: Reading = Reading()
    @Published var params: Params = Params()
    @Published var isConnected = false // updates connection status bar in ui
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("Mqtt didConnectAck", ack.description)
        
        if ack.description == "accept" {
            mqtt.subscribe("outtopic")
            self.isConnected = true
        } else {
            print("broker connection failed!")
            self.isConnected = false
        }
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("Message published on topic \(message.topic) with payload \(message.string!)")
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        print("Message received in topic \(message.topic) with payload \(message.string!)")
        let readingData = message.string!
        
        // parse json
        let jsonData = readingData.data(using: .utf8)!
        reading = try! JSONDecoder().decode(Reading.self, from: jsonData)
        
        // Remove 'V', 'kWh', etc. and build the Params obj
        reading.Voltage.removeLast()
        reading.Current.removeLast()
        reading.Power.removeLast()
        reading.Energy.removeLast()
        reading.Energy.removeLast()
        reading.Energy.removeLast()
        reading.Frequency.removeLast()
        reading.Frequency.removeLast()
        
        params.voltage = Double(reading.Voltage)!
        params.current = Double(reading.Current)!
        params.power = Double(reading.Power)!
        params.energy = Double(reading.Energy)!
        params.frequency = Double(reading.Frequency)!
        params.pf = Double(reading.PF)!
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
    
    func configureMQTT() {
        let clientID = "iphone12"
        let host = "broker.hivemq.com"
        let port = UInt16(1883)
        staticMQTT.mqttClient = CocoaMQTT(clientID: clientID, host: host, port: port)
        staticMQTT.mqttClient.username = ""
        staticMQTT.mqttClient.password = ""
        staticMQTT.mqttClient.keepAlive = 60
        staticMQTT.mqttClient.delegate = self
        let _ = staticMQTT.mqttClient.connect()
        //staticMQTT.mqttClient.publish("intopic", withString: "hello")
        
    }
    
    func sendMessage(topic:String, message:String){
        staticMQTT.mqttClient.publish(topic, withString: message)
    }
    
}
