//
//  CustomBarChart.swift
//  Powermon
//
//  Created by vshandil on 05/01/25.
//

import SwiftUI

struct CustomBarChart: View {
    let usages: [Usage] // Assume Usage is a struct with power and timestamp
    
    var body: some View {
        let maxPower = usages.map(\.power).max() ?? 1 // Avoid division by zero
        let scaleFactor: CGFloat = 150.0 / CGFloat(maxPower) // Chart area height
        
        GeometryReader { geometry in
            let dynamicSpacing = max(11, geometry.size.width / CGFloat(usages.count) * 0.1) // Adjust spacing dynamically
            
            VStack {
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
                                    .stroke(Color("BarOutline"), lineWidth: 1) // Outline with stroke
                                Rectangle()
                                    .fill(Color.green)
                            }
                            .frame(width: 20, height: CGFloat(usage.power) * scaleFactor)
                            .padding(.vertical)

                            Text(formatTime(usage.timestamp))
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
    }
    
    func formatTime(_ timestamp: String) -> String {
        // Create an ISO 8601 DateFormatter
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        // Convert the string to a Date
        if let date = isoFormatter.date(from: timestamp) {
            // Format the Date to a readable string
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a" // Adjust the format as needed (e.g., "10:30 AM")
            return dateFormatter.string(from: date)
        } else {
            return "Invalid Date" // Handle parsing failure
        }
    }
    
    
}
