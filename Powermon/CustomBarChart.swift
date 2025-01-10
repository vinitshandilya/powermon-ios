import SwiftUI

struct CustomBarChart: View {
    let usages: [EnergyReading]
    let category: String
    let chartTitle: String
    
    var body: some View {
        let maxPower = usages.map(\.power).max() ?? 1 // Avoid division by zero
        let scaleFactor: CGFloat = 130.0 / CGFloat(maxPower) // Chart area height
        
        GeometryReader { geometry in
            let dynamicSpacing = max(11, geometry.size.width / CGFloat(usages.count) * 0.1) // Adjust spacing dynamically
            
            HStack(alignment: .bottom, spacing: dynamicSpacing) { // chart area
                ForEach(usages) { usage in
                    VStack(alignment: .center, spacing: 5) { // individual bar
                        Text("\(usage.power) W")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .rotationEffect(.degrees(90))
                            .fixedSize()
                            .frame(width: 20, alignment: .center)

                        ZStack {
                            Rectangle()
                                .stroke(Color("BarOutline"), lineWidth: 0.8)
                            Rectangle()
                                .fill(Color.green)
                        }
                        .frame(width: 20, height: CGFloat(usage.power) * scaleFactor)
                        .padding(.vertical)

                        Text(formatTime(timestamp: usage.timestamp))
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .rotationEffect(.degrees(90))
                            .fixedSize()
                            .frame(width: 20, alignment: .center)
                            .padding(.vertical, 5)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 20)
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
