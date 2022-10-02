//
//  ChartUI.swift
//  Powermon
//
//  Created by vshandil on 27/09/22.
//

import Charts
import SwiftUI

struct ChartUI: View {
    
    let lineseries: [DataPoint]
    @State private var sliderValue : Float = 0.0
    
    var body: some View {
        ScrollView {
            Text("Energy Usage (kWh)")
                .font(.system(size: 25))
                .foregroundColor(.gray)
            Divider()
            Chart {
                ForEach(lineseries.suffix(31-Int(sliderValue))) { point in
                    LineMark(
                        x: .value("Timestamp", point.timestamp),
                        y: .value("Usage", point.usage)
                    )
                    .interpolationMethod(.catmullRom)
                }
                //.foregroundStyle(by: .value("Energy", "Usage"))
                .symbol(by: .value("Energy", "kWh"))
            }
            //.chartYScale(domain: 869.5...871.5)
            .frame(height: 400)
            .safeAreaInset(edge: .top, alignment: .center, spacing: 0) {
                Color.clear
                    .frame(height: 20)
                    .background(Material.bar)
            }
            .chartPlotStyle { plotArea in
                plotArea
                    .background(.blue.opacity(0.1))
                //.foregroundColor(Color.green)
            }
            
            HStack {
                Text("From: \(lineseries[Int(sliderValue)].timestamp)")
                Spacer()
                Text("To: \(lineseries.last?.timestamp ?? "-")")
            }
            .padding(.horizontal)
            .font(.system(size: 12))
            
            VStack {
                //Text("Current Slider Value: \(Int(sliderValue))")
                Slider(value: $sliderValue, in: 0...24) { // 31-7 = 24 datapoints to keep at least
                    Text("Usage")
                } minimumValueLabel: {
                    //Text("Month").fontWeight(.thin)
                } maximumValueLabel: {
                    //Text("Day").fontWeight(.thin)
                }.tint(.accentColor)
                    .padding()
            }
            
            Divider()
            Text("This shows the trend of electricity consumption in the last 31 minutes. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. This shows the trend of electricity consumption in the last 31 minutes. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
                .padding()
            Spacer()
        }
    }
}

struct ChartUI_Previews: PreviewProvider {
    
    static var previews: some View {
        ChartUI(lineseries: [
            DataPoint(timestamp: "1/2/3", usage: 843.0),
            DataPoint(timestamp: "2/2/3", usage: 743.3),
            DataPoint(timestamp: "3/2/3", usage: 643.0),
            DataPoint(timestamp: "4/2/3", usage: 843.0),
            DataPoint(timestamp: "5/2/3", usage: 200.0),
            DataPoint(timestamp: "6/2/3", usage: 730.0),
            DataPoint(timestamp: "7/2/3", usage: 425.0),
            DataPoint(timestamp: "8/2/3", usage: 333.0),
            DataPoint(timestamp: "9/2/3", usage: 765.0),
            DataPoint(timestamp: "10/2/3", usage: 110.2),
            DataPoint(timestamp: "11/2/3", usage: 430.2)
        ])
    }
}
