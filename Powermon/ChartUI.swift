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
    @State private var slider1Value : Float = 0.0
    @State private var slider2Value : Float = 0.0
    
    var body: some View {
        ScrollView {
            
            // Rate graph!
            // Making edits
            
            let spikes = getAverageUsageArray(series: lineseries)
            let brr = spikes[Int(slider2Value)..<min(Int(slider2Value)+7, spikes.count)]
            
            spikes.count >= 1 ? VStack {
                Text("Energy usage by hour".uppercased())
                    .font(.system(size: 15))
                    .opacity(0.7)
                Divider()
                
                Chart {
                    ForEach(brr) { point in
                        BarMark(
                            x: .value("Timestamp", TimestampFormatter(timestamp: point.timestamp, format: "h:mm a").getFormattedLabel()),
                            y: .value("Usage", point.usage)
                        )
                        .annotation(position: .overlay, alignment: .top) {
                            Text("\(point.usage, format: .number.precision(.fractionLength(2)))")
                                .foregroundColor(.white)
                                .font(.system(size: 8, weight: .heavy, design: .default))
                            
                        }
                    }
                    // .symbol(by: .value("Energy", "kWh"))
                }
                //.chartYScale(domain: 869.5...871.5)
                .frame(height: 400)
                .chartPlotStyle { plotArea in
                    plotArea
                        .background(.cyan.opacity(0.1))
                        .foregroundColor(Color.cyan)
                }
                HStack {
                    Text("From: \(TimestampFormatter(timestamp: brr[Int(slider2Value)].timestamp, format: "MMM d, h:mm a").getFormattedLabel())")
                    Spacer()
                    Text("From: \(TimestampFormatter(timestamp: (brr.last?.timestamp ?? ""), format: "MMM d, h:mm a").getFormattedLabel())")
                }
                .padding(.horizontal)
                .font(.system(size: 12))
                .opacity(0.5)
                
                VStack {
                    // if lineseries has less than 7 elements, don't show slider bar
                    Float(max(0, lineseries.count-7)) > 0 ?
                    Slider(value: $slider2Value, in: 0...Float(max(0, lineseries.count-7))) {
                        Text("Usage")
                    } minimumValueLabel: {
                        //Text("Month").fontWeight(.thin)
                    } maximumValueLabel: {
                        //Text("Day").fontWeight(.thin)
                    }
                    .tint(.cyan)
                    .padding()
                    .onAppear {
                        self.slider2Value = Float(max(0, lineseries.count-7))
                    }
                    : nil
                    
                }
                
            } : nil
            
            Text("Accumulated usage".uppercased())
                .font(.system(size: 15))
                .opacity(0.7)
            Divider()
            
            
            let arr = lineseries[Int(slider1Value)..<min(Int(slider1Value)+7, lineseries.count)]
            Chart {
                ForEach(arr) { point in
                    BarMark(
                        x: .value("Timestamp", TimestampFormatter(timestamp: point.timestamp, format: "h:mm a").getFormattedLabel()),
                        y: .value("Usage", point.usage)
                    )
                    .annotation(position: .overlay, alignment: .top) {
                        Text("\(point.usage, format: .number.precision(.fractionLength(2)))")
                            .foregroundColor(.white)
                            .font(.system(size: 8, weight: .heavy, design: .default))
                        
                    }
                }
                // .symbol(by: .value("Energy", "kWh"))
            }
            //.chartYScale(domain: 869.5...871.5)
            .frame(height: 400)
            .chartPlotStyle { plotArea in
                plotArea
                    .background(.black.opacity(0.1))
                    .foregroundColor(Color.black)
            }
            
            HStack {
                Text("From: \(TimestampFormatter(timestamp: arr[Int(slider1Value)].timestamp, format: "MMM d, h:mm a").getFormattedLabel())")
                Spacer()
                Text("To: \(TimestampFormatter(timestamp: (arr.last?.timestamp ?? ""), format: "MMM d, h:mm a").getFormattedLabel())")
            }
            .padding(.horizontal)
            .font(.system(size: 12))
            .opacity(0.5)
            
            VStack {
                // if lineseries has less than 7 elements, don't show slider bar
                Float(max(0, lineseries.count-7)) > 0 ?
                Slider(value: $slider1Value, in: 0...Float(max(0, lineseries.count-7))) {
                    Text("Usage")
                } minimumValueLabel: {
                    //Text("Month").fontWeight(.thin)
                } maximumValueLabel: {
                    //Text("Day").fontWeight(.thin)
                }
                .tint(.black)
                .padding()
                .onAppear {
                    self.slider1Value = Float(max(0, lineseries.count-7))
                }
                : nil
                
            }
            
            
            Divider()
            Text("This shows the trend of electricity consumption in the 7 hours. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. This shows the trend of electricity consumption in the last 7 hours. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
                .padding()
                .opacity(0.7)
        }
    }
    
    func getAverageUsageArray(series: [DataPoint]) -> [DataPoint] {
        var deltaseries: [DataPoint] = []
        for i in 0..<series.count-1 {
            let deltaUsage: Double = series[i+1].usage - series[i].usage
            let timeinterval: Double = getTimeInterval(from: series[i].timestamp, to: series[i+1].timestamp)/60/60
            let rate = deltaUsage/timeinterval
            //            print("Timestamp: \(TimestampFormatter(timestamp: series[i].timestamp, format: "MMM d, h:mm a").getFormattedLabel()) Rate: \(rate) raw_ts: \(series[i].timestamp)")
            deltaseries.append(DataPoint(timestamp: series[i+1].timestamp, usage: rate))
        }
        return deltaseries
    }
    
    func getTimeInterval(from: String, to: String) -> Double {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm:ss a"
        let startdate: Date = dateFormatter.date(from: from)!
        let enddate: Date = dateFormatter.date(from: to)!
        return (enddate.timeIntervalSince1970 - startdate.timeIntervalSince1970)
    }
}

struct ChartUI_Previews: PreviewProvider {
    
    static var previews: some View {
        ChartUI(lineseries: [
            DataPoint(timestamp: "9/30/2022 3:37:59 AM", usage: 643.0),
            DataPoint(timestamp: "10/1/2022 4:37:59 AM", usage: 743.0),
            DataPoint(timestamp: "10/2/2022 5:37:59 AM", usage: 843.0),
            DataPoint(timestamp: "10/3/2022 6:37:59 AM", usage: 943.0),
            DataPoint(timestamp: "10/4/2022 7:37:59 AM", usage: 1000.0),
            DataPoint(timestamp: "10/5/2022 8:37:59 AM", usage: 1100.0),
            DataPoint(timestamp: "10/6/2022 9:37:59 AM", usage: 1200.0),
            DataPoint(timestamp: "10/7/2022 10:37:59 AM", usage: 1300.0),
            DataPoint(timestamp: "10/8/2022 11:37:59 AM", usage: 1400.0)
        ])
    }
}
