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
                mqttmanager.isConnected ? ConnStatusBar(status: "connected") : ConnStatusBar(status: "offline")
                //ChartUI(lineseries: datapoints.getSeriesData())
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
            .navigationTitle("Reading")
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
