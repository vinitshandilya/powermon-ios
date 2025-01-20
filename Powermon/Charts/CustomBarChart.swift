import SwiftUI

struct CustomBarChart: View {
    let usages: [EnergyReading]
    let category: String
    let chartTitle: String
    
    var body: some View {
        let maxPower = usages.map(\.power).max() ?? 1 // Avoid division by zero
        
        GeometryReader { parentGeometry in
            
            VStack(alignment: .center, spacing: 0) {
                Text(chartTitle)
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.primary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical)
//                    .background(.blue.opacity(0.1))
                
                Spacer()
                
                GeometryReader { geometry in
                    let scaleFactor: CGFloat = geometry.size.height / CGFloat(maxPower)
                    let dynamicSpacing = max(11, geometry.size.width / CGFloat(usages.count) * 0.1) // Adjust spacing dynamically
                    
                    VStack(alignment: .center, spacing: 0) {
                        HStack(alignment: .bottom, spacing: dynamicSpacing) { // half height of chart container
                            ForEach(usages) { usage in
                                VStack(alignment: .center) { // Individual bar
                                    Text("\(usage.power) W")
                                        .font(.caption2)
                                        .foregroundColor(.primary)
                                        .rotationEffect(.degrees(90))
                                        .fixedSize()
                                        .frame(width: 20, alignment: .center)
                                        .padding(.bottom, 10)
                                    
                                    Rectangle()
                                        .fill(Color.green)
                                        .frame(width: 20, height: CGFloat(usage.power) * scaleFactor)
                                    
                                    Text(formatTime(timestamp: usage.timestamp))
                                        .font(.caption2)
                                        .foregroundColor(.primary)
                                        .rotationEffect(.degrees(90))
                                        .fixedSize()
                                        .frame(width: 20, alignment: .center)
                                        .padding(.vertical, 20)
                                }
                            }
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottom)
                }
                .frame(width: parentGeometry.size.width, height: parentGeometry.size.height * 0.4)
//                .background(.green.opacity(0.1))
            }
//            .background(.pink.opacity(0.1))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }

        
    }

    func formatTime(timestamp: String) -> String {
        var weeknum: String = "-"
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        // Convert the string to a Date
        if let date = isoFormatter.date(from: timestamp) {
            let dateFormatter = DateFormatter()
            let calendar = Calendar.current
            
            if let weekOfYear = calendar.dateComponents([.weekOfYear], from: date).weekOfYear {
                weeknum = "Week \(weekOfYear)"
            }
            
            switch self.category {
            case "byHour": dateFormatter.dateFormat = "hh:mm a"
            case "byDay": dateFormatter.dateFormat = "EEE dd MMM"
            case "byMonth": dateFormatter.dateFormat = "MMMM yyyy"
            case "byWeek": 
                return weeknum
            default: dateFormatter.dateFormat = "dd/MM EEE hh:mm a"
            }
            
            return dateFormatter.string(from: date)
        } else {
            return "Invalid Date" // Handle parsing failure
        }
    }
    
    
}
