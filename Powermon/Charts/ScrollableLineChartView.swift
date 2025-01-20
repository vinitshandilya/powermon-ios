import SwiftUI
import Charts

struct ScrollableLineChartView: View {
    let usages: [EnergyReading]
    var chartColor: Color = Color.blue
    let timeFormatter = TimeFormatter()
    
    var body: some View {
        
        GeometryReader { parentGeometry in
            VStack(alignment: .center, spacing: 0) {
                Text("Energy Usage Trend")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.primary)
                    .padding(.vertical)
                
                ScrollView(.horizontal) {
                    Chart(usages) { reading in
                        // Area chart fill
                        AreaMark(
                            x: .value("Timestamp", reading.timestamp),
                            y: .value("Power", reading.power)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(LinearGradient(
                            gradient: Gradient(colors: [chartColor.opacity(0.3), chartColor.opacity(0.7)]),
                            startPoint: .bottom,
                            endPoint: .top
                        ))
                        
                        // Line chart
                        LineMark(
                            x: .value("Timestamp", reading.timestamp),
                            y: .value("Power", reading.power)
                        )
                        .foregroundStyle(chartColor)
                        .interpolationMethod(.catmullRom)
                        
                        // Annotations on the line
                        PointMark(
                            x: .value("Timestamp", reading.timestamp),
                            y: .value("Power", reading.power)
                        )
                        .symbol(.circle)
                        .foregroundStyle(chartColor)
                        .annotation(position: .top) {
                            Text("\(reading.power)")
                                .font(.caption2)
                                .foregroundColor(Color.primary)
                                .padding(2)
                        }
                    }
                    .padding(.top, 20)
                    .chartXAxis {
                        AxisMarks { value in
                            AxisValueLabel {
                                if let timestamp = value.as(String.self) {
                                    let axisLabel = timeFormatter.formatTime(timestamp: timestamp)
                                    Text(axisLabel)
                                        .font(.system(size: 10))
                                        .fontWeight(.light)
                                        .foregroundColor(.primary)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .frame(width: 40)
                                        .multilineTextAlignment(.center)
                                }
                            }
                        }
                    }
                    .padding(.bottom)
                    .chartYAxis {
                        AxisMarks(position: .leading) { _ in
                            // Exclude the grid lines by not adding them here
                            AxisTick() // Keep ticks
                            // AxisValueLabel() // Keep labels
                            // No AxisGridLine(), so gridlines won't be drawn
                        }
                    }
                    .frame(width: max(CGFloat(usages.count) * 50, UIScreen.main.bounds.width), height: parentGeometry.size.height * 0.8)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }



    
    func formatTime(timestamp: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: timestamp) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM hh:mm a"
            return dateFormatter.string(from: date)
        } else {
            return "Invalid Date" // Handle parsing failure
        }
    }
}
