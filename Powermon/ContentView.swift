//
//  ContentView.swift
//  Powermon
//
//  Created by vshandil on 09/05/22.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase // detects application lifecycle
    @StateObject var mqttmanager = MQTTManager()
    @StateObject var usageHistory: UsageHistory = UsageHistory()
    
    var body: some View {
        NavigationView {
            VStack {
                mqttmanager.isConnected ? (mqttmanager.alarm ? ConnStatusBar(status: "highusage") : ConnStatusBar(status: "nominal")) : ConnStatusBar(status: "offline")
                
                Form {
                    Section(header: Text("Live reading")) {
                        
                        HStack {
                            Label("Power", systemImage: "bolt.circle").fontWeight(.heavy)
                            Spacer()
                            mqttmanager.params.power > 400 ? (Text(String(mqttmanager.params.power)).foregroundColor(Color.red).fontWeight(.light) + Text(" W").foregroundColor(Color.red)).fontWeight(.light) : Text(String(mqttmanager.params.power)).fontWeight(.light) + Text(" W").fontWeight(.light)
                        }
                        HStack {
                            Label("Voltage", systemImage: "powerplug").fontWeight(.heavy)
                            Spacer()
                            Text(String(mqttmanager.params.voltage)).fontWeight(.light) + Text(" V").fontWeight(.light)
                        }
                        HStack {
                            Label("Current", systemImage: "alternatingcurrent").fontWeight(.heavy)
                            Spacer()
                            Text(String(mqttmanager.params.current)).fontWeight(.light) + Text(" A").fontWeight(.light)
                        }
                        HStack {
                            Label("Units", systemImage: "barometer").fontWeight(.heavy)
                            Spacer()
                            Text(String(mqttmanager.params.energy)).fontWeight(.light) + Text(" kWh").fontWeight(.light)
                        }
                        HStack {
                            Label("Freq", systemImage: "waveform").fontWeight(.heavy)
                            Spacer()
                            Text(String(mqttmanager.params.frequency)).fontWeight(.light) + Text(" Hz").fontWeight(.light)
                        }
                        HStack {
                            Label("PF", systemImage: "poweroff").fontWeight(.heavy)
                            Spacer()
                            Text(String(mqttmanager.params.pf)).fontWeight(.light)
                        }
                    }
                }
                .font(.footnote)
                
                ZStack {
                    
                    List {
                        Section(header: Text("Hourly Trend for the month")) {
    //                      // line is an array of DataPoints
                            ForEach(usageHistory.line.reversed(), id: \.id) { datapoint in
                                HStack {
                                    Text(String(datapoint.timestamp))
                                    Spacer()
                                    Text(String(datapoint.usage)) + Text(" kWh")
                                }
                                .font(.footnote)
                            }
                        }
                    }
                    if usageHistory.line.count <= 0 {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                            //.scaleEffect(3)
                    }
                }
            }
            .navigationTitle("Powermon")
            //.navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    ResetButton(mqttmgr: mqttmanager)
                    // Pass line variable from UsageHistory class to ChartUI.
                    // line is a published variable in UsageHistory, and we
                    // are watching this class for any changes using @State-
                    // -Observer wrapper. :-)
                    if usageHistory.line.count > 0 {
                        NavigationLink(destination: ChartUI(lineseries: usageHistory.line)) {
                            Text("Analyse").foregroundColor(.white)
                        }
                    }
                }
            }
        }
        .onAppear {
            //mqttmanager.configureMQTT()
            //usageHistory.fetch()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .inactive {
                print("Inactive")
            } else if newPhase == .active {
                print("Active")
                mqttmanager.configureMQTT()
                usageHistory.fetch()
                
            } else if newPhase == .background {
                print("Background")
            }
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
