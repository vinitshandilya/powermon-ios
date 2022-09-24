//
//  ContentView.swift
//  Powermon
//
//  Created by vshandil on 09/05/22.
//

import SwiftUI

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
                    Section(header: Text("Trend")) {
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


