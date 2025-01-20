import SwiftUI
import Charts

struct ScrollableBarChart: View {
    let usages: [EnergyReading]
    let category: String
    let chartTitle: String
    @State private var nominalUsage: Double = UserDefaults.standard.double(forKey: "nominalUsage") == 0 ? 500 : UserDefaults.standard.double(forKey: "nominalUsage")
    @State private var maximumUsage: Double = UserDefaults.standard.double(forKey: "maximumUsage") == 0 ? 1000 : UserDefaults.standard.double(forKey: "maximumUsage")

    var body: some View {
        
        GeometryReader { parentGeometry in
            VStack(alignment: .center, spacing: 0) {
                Text(chartTitle)
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.primary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical)
               
                ScrollView(.horizontal) {
                    let barWidth: CGFloat = 50 // Adjust this to control individual bar width
                    let totalWidth = CGFloat(usages.count) * barWidth

                    Chart(usages) { usage in
                        BarMark(
                            x: .value("Time", formatTime(timestamp: usage.timestamp)),
                            y: .value("Power (W)", usage.power)
                        )
                        .foregroundStyle(.green) // This will eventually plot the hourly usage delta
                        .annotation(position: .top) {
                            Text("\(Int(usage.power)) W")
                                .font(.system(size: 10))
                                .fontWeight(.light)
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(width: 40)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(width: max(totalWidth, UIScreen.main.bounds.width), height: parentGeometry.size.height * 0.75)
                    .chartXAxis {
                        AxisMarks { value in
                            AxisValueLabel { // Customize x-axis labels
                                if let timestamp = value.as(String.self) {
                                    Text(timestamp)
                                        .font(.system(size: 10))
                                        .fontWeight(.light)
                                        .foregroundColor(.primary)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .frame(width: 40)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            AxisTick() // Optional: Adds tick marks under labels
                            //AxisGridLine()
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { _ in
                            AxisTick() // Keep ticks
                            // AxisValueLabel()
                            // AxisGridLine()
                        }
                    }
    //                .chartXAxisLabel(position: .bottom, alignment: .center) { // X-axis title
    //                    Text("Time")
    //                        .font(.headline)
    //                        .foregroundColor(.primary)
    //                }
    //                .chartYAxisLabel(position: .leading, alignment: .center) { // Y-axis title
    //                    Text("Power (W)")
    //                        .font(.headline)
    //                        .foregroundColor(.primary)
    //                }
                    .padding()

                }
                
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            
        }
        
        
    }
    
    private func getColor(for value: Int) -> Color {
        if value < Int(nominalUsage) {
            return .green
        } else if value < Int(maximumUsage) {
            return .orange
        } else {
            return .red
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

//    func formatTime(timestamp: String) -> String {
//        var weeknum: String = "-"
//        let isoFormatter = ISO8601DateFormatter()
//        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
//        
//        // Convert the string to a Date
//        if let date = isoFormatter.date(from: timestamp) {
//            let dateFormatter = DateFormatter()
//            let calendar = Calendar.current
//            
//            if let weekOfYear = calendar.dateComponents([.weekOfYear], from: date).weekOfYear {
//                weeknum = "Week \(weekOfYear)"
//            }
//            
//            switch self.category {
//            case "byHour": dateFormatter.dateFormat = "hh:mm a"
//            case "byDay": dateFormatter.dateFormat = "EEE dd MMM"
//            case "byMonth": dateFormatter.dateFormat = "MMMM yyyy"
//            case "byWeek":
//                return weeknum
//            default: dateFormatter.dateFormat = "dd/MM EEE hh:mm a"
//            }
//            
//            return dateFormatter.string(from: date)
//        } else {
//            return "Invalid Date" // Handle parsing failure
//        }
//    }
}
