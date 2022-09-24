//
//  ContentView.swift
//  Powermon
//
//  Created by vshandil on 09/05/22.
//

import SwiftUI
import CocoaMQTT

struct Reading: Hashable, Codable {
    var Voltage: String = ""
    var Current: String = ""
    var Power: String = ""
    var Energy: String = ""
    var Frequency: String = ""
    var PF: String = ""
}

struct Params: Hashable {
    var voltage: Double = 0.00
    var current: Double = 0.00
    var power: Double = 0.000
    var energy: Double = 0.000
    var frequency: Double = 0.00
    var pf: Double = 0.0
}

class MQTTManager: CocoaMQTTDelegate, ObservableObject {
    var reading: Reading = Reading()
    @Published var params: Params = Params()
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("Mqtt didConnectAck", ack.description)
        
        if ack.description == "accept" {
            mqtt.subscribe("outtopic")
        } else {
            print("broker connection failed!")
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
        staticMQTT.mqttClient.connect()
        //staticMQTT.mqttClient.publish("intopic", withString: "hello")
        
    }
    
    func sendMessage(topic:String, message:String){
        staticMQTT.mqttClient.publish(topic, withString: message)
    }
    
}

struct DailyUsage: Hashable, Codable {
    var _id: String = ""
    var timestamp: String = ""
    var energyUsage: String = ""
}

class UsageHistory: ObservableObject, Identifiable {
    
    @Published var dailyusage: [DailyUsage] = []

    func fetch() {
        let urlString = "https://pzem004t.herokuapp.com/getusagehistory"
        let url = URL(string: urlString)
        
        guard url != nil else {
            return
        }
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url!) { [weak self] data, response, error in
            if error == nil && data != nil {
                // Parse JSON
                let decoder = JSONDecoder()
                do {
                    let dailyusage = try decoder.decode([DailyUsage].self, from: data!)
                    print(dailyusage)
                    DispatchQueue.main.async {
                        self?.dailyusage = dailyusage
                    }
                    
                } catch {
                    print("Error parsing JSON!")
                }
                
            } else {
                print(error!)
            }
        }
        dataTask.resume()
    }
}


struct ContentView: View {
    @StateObject var mqttmanager = MQTTManager()
    @StateObject var usageHistory: UsageHistory = UsageHistory()
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Live reading")) {
                        
                        HStack {
                            Label("Power", systemImage: "bolt.circle")
                            Spacer()
                            mqttmanager.params.power > 400 ? (Text(String(mqttmanager.params.power)).foregroundColor(Color.red) + Text(" W").foregroundColor(Color.red)) : Text(String(mqttmanager.params.power)) + Text(" W")
                        }
                        HStack {
                            Label("Voltage", systemImage: "powerplug")
                            Spacer()
                            Text(String(mqttmanager.params.voltage)) + Text(" V")
                        }
                        HStack {
                            Label("Current", systemImage: "alternatingcurrent")
                            Spacer()
                            Text(String(mqttmanager.params.current)) + Text(" A")
                        }
                        HStack {
                            Label("Units", systemImage: "barometer")
                            Spacer()
                            Text(String(mqttmanager.params.energy)) + Text(" kWh")
                        }
                        HStack {
                            Label("Freq", systemImage: "waveform")
                            Spacer()
                            Text(String(mqttmanager.params.frequency)) + Text(" Hz")
                        }
                        HStack {
                            Label("PF", systemImage: "poweroff")
                            Spacer()
                            Text(String(mqttmanager.params.pf))
                        }
                        
                    }
                    
                }
                
                List {
                    Section(header: Text("Hourly Trend")) {
                        ForEach(usageHistory.dailyusage, id: \.self) { elem in
                            HStack {
                                Text(String(elem.timestamp))
                                Spacer()
                                Text(String(elem.energyUsage)) + Text(" kWh")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Reading")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    ResetButton(mqttmgr: mqttmanager)
                }
            }
        }
        .onAppear {
            mqttmanager.configureMQTT()
            usageHistory.fetch()
        }
    }
}

struct ResetButton: View {
    var mqttmgr: MQTTManager
    @State private var isPresentingConfirm: Bool = false
    
    var body: some View {
        Button("Reset", role: .destructive) {
            isPresentingConfirm = true
        }
        .confirmationDialog("Are you sure?", isPresented: $isPresentingConfirm) {
            // publishing "1" on intopic will reset the module
            Button("Reset usage?", role: .destructive) { mqttmgr.sendMessage(topic: "intopic", message: "1")}
        }
        message: {
            Text("Accumulated usage will be reset. You cannot undo this")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .previewInterfaceOrientation(.portrait)
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}


