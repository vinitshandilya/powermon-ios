//
//  ChartUI.swift
//  Powermon
//
//  Created by vshandil on 27/09/22.
//

import Charts
import Foundation
import SwiftUI

struct ChartUI: View {
    
    let lineseries: [DataPoint]
    @State private var sliderValue : Float = 0.0
    
    var body: some View {
        ScrollView {
            Text("Energy usage by hour")
                .font(.system(size: 20))
                .opacity(0.7)
            Divider()
            let arr = lineseries[Int(sliderValue)..<min(Int(sliderValue)+7, lineseries.count)]
            Chart {
                ForEach(arr) { point in
                    BarMark(
                        // x: .value("Timestamp", getFormattedLabel(str: point.timestamp, format: "hh:mm a")),
                        x: .value("Timestamp", TimestampFormatter(timestamp: point.timestamp, format: "h:mm a").getFormattedLabel()),
                        y: .value("Usage", point.usage)
                    )
                    .annotation(position: .overlay, alignment: .top) {
                        Text("\(point.usage, format: .number.precision(.fractionLength(1)))")
                            .foregroundColor(.white)
                            .font(.system(size: 8, weight: .heavy, design: .default))
                      
                    }
                }
                .symbol(by: .value("Energy", "kWh"))
            }
            //.chartYScale(domain: 869.5...871.5)
            .frame(height: 400)
            .chartPlotStyle { plotArea in
                plotArea
                    .background(.blue.opacity(0.1))
                //.foregroundColor(Color.green)
            }
            
            HStack {
                Text("From: \(TimestampFormatter(timestamp: arr[Int(sliderValue)].timestamp, format: "MMM d, h:mm a").getFormattedLabel())")
                Spacer()
                Text("To: \(TimestampFormatter(timestamp: (arr.last?.timestamp ?? ""), format: "MMM d, h:mm a").getFormattedLabel())")
            }
            .padding(.horizontal)
            .font(.system(size: 12))
            .opacity(0.5)
            
            VStack {
                // if lineseries has less than 7 elements, don't show slider bar
                Float(max(0, lineseries.count-7)) > 0 ?
                Slider(value: $sliderValue, in: 0...Float(max(0, lineseries.count-7))) {
                    Text("Usage")
                } minimumValueLabel: {
                    //Text("Month").fontWeight(.thin)
                } maximumValueLabel: {
                    //Text("Day").fontWeight(.thin)
                }
                .tint(.accentColor)
                .padding()
                .onAppear {
                    self.sliderValue = Float(max(0, lineseries.count-7))
                }
                : nil
                
            }
            
            Divider()
            Text("This shows the trend of electricity consumption in the 7 hours. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. This shows the trend of electricity consumption in the last 7 hours. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
                .padding()
                .opacity(0.7)
            Spacer()
        }
    }
}

struct ChartUI_Previews: PreviewProvider {
    
    static var previews: some View {
        ChartUI(lineseries: [
            DataPoint(timestamp: "9/30/2022 3:37:59 AM", usage: 643.0),
            DataPoint(timestamp: "10/1/2022 4:37:59 AM", usage: 843.0),
            DataPoint(timestamp: "10/2/2022 5:37:59 AM", usage: 200.0),
            DataPoint(timestamp: "10/3/2022 6:37:59 AM", usage: 730.0),
            DataPoint(timestamp: "10/4/2022 7:37:59 AM", usage: 425.0),
            DataPoint(timestamp: "10/5/2022 8:37:59 AM", usage: 333.0),
            DataPoint(timestamp: "10/6/2022 9:37:59 AM", usage: 765.0),
            DataPoint(timestamp: "10/7/2022 10:37:59 AM", usage: 110.2),
            DataPoint(timestamp: "10/8/2022 11:37:59 AM", usage: 430.2)
        ])
    }
}
