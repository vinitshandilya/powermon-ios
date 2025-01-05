import SwiftUI

struct SemiCircularChart: View {
    var value: Double // Accept value as an input
    let minValue: Double
    let maxValue: Double
    var isMqttConnected: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background arc (always a semi-circle)
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                    .rotationEffect(.degrees(135))
                
                // Foreground arc
                Circle()
                    .trim(from: 0, to: min(1.0, CGFloat(value / maxValue) * 0.5))
                    .stroke(getColor(for: value), lineWidth: 20)
                    .rotationEffect(.degrees(135))
                    .animation(.easeInOut(duration: 0.5), value: value)
                
                // Center value text
                if isMqttConnected {
                    VStack(alignment: .center) {
                        // Display value in kW if value exceeds 1100
                        if value > 1100 {
                            Text(String(format: "%.2f", value / 1000.0))
                                .font(.title)
                                .fontWeight(.black)
                            Text("kW")
                                .font(.body)
                        } else {
                            Text(String(value))
                                .font(.title)
                                .fontWeight(.black)
                            Text("Watts")
                                .font(.body)
                        }
                    }
                    .foregroundColor(getColor(for: value))
                } else {
                    ProgressView().scaleEffect(0.8)
                }
                
                
            }
            .frame(width: geometry.size.width, height: geometry.size.width / 2)
        }
        .frame(height: 150) // Adjust the height for the semi-circle
        .padding()
    }
    
    
    /// Determines the color based on the value
    private func getColor(for value: Double) -> Color {
        if value < minValue {
            return .green
        } else if value < maxValue {
            return .orange
        } else {
            return .red
        }
    }
}


struct SemiCircularChart_Previews: PreviewProvider {
    static var previews: some View {
        SemiCircularChart(value: 300, minValue: 500, maxValue: 1000, isMqttConnected: true)
    }
}

