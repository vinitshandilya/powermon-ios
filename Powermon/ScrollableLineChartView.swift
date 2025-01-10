import SwiftUI
import Charts

struct ScrollableLineChartView: View {
    let usages: [EnergyReading]
    var chartColor: Color = Color.blue
    let timeFormatter = TimeFormatter()
    
    var body: some View {
        VStack {
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
                            // .background(Color.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 5))
                    }
                }
                .padding(.top, 20)
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let timestamp = value.as(String.self) {
                                let axisLabel = timeFormatter.formatTime(timestamp: timestamp)
                                if axisLabel.count > 10 {
                                    Text(axisLabel)
                                        .font(.system(size: 10))
                                        .fontWeight(.bold)
//                                        .rotationEffect(.degrees(90))
                                        .fixedSize(horizontal: false, vertical: true) // Ensures the text does not stretch
                                        .frame(width: 40) // Fixed width for the timestamp label
                                        .padding(.top, 5)
                                        .multilineTextAlignment(.center)
                                } else {
                                    Text(axisLabel)
                                        .font(.system(size: 10))
                                        .fontWeight(.light)
                                        .foregroundColor(.gray)
//                                        .rotationEffect(.degrees(90))
                                        .fixedSize(horizontal: false, vertical: true) // Ensures the text does not stretch
                                        .frame(width: 40) // Fixed width for the timestamp label
                                        .padding(.top, 5)
                                        .multilineTextAlignment(.center)
                                }
                            }
                        }
                    }
                }
                .frame(width: max(CGFloat(usages.count) * 50, UIScreen.main.bounds.width), height: 300)
            }
        }
        .frame(maxWidth: .infinity)
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
