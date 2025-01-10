import SwiftUI

struct RingWidgetTable: View {
    let device_id: String
    let reading: MQTTReading
    let minValue: Double
    let maxValue: Double
    var isMqttConnected: Bool
    
    var isRightDevice: Bool {
        device_id == reading.device_id
    }
    
    var power: Double {
        reading.power
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background arc (always a semi-circle)
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                    .rotationEffect(.degrees(135))
                
                if isMqttConnected {
                    if isRightDevice {
                        Circle()
                            .trim(from: 0, to: min(1.0, CGFloat(power / maxValue) * 0.5))
                            .stroke(getColor(for: power), lineWidth: 20)
                            .rotationEffect(.degrees(135))
                            .animation(.easeInOut(duration: 0.5), value: power)
                        
                        // Center text
                        VStack(alignment: .center) {
                            if power > 2000 {
                                Text(String(format: "%.2f", power / 1000.0))
                                    .font(.title)
                                    .fontWeight(.black)
                                Text("kW")
                                    .font(.body)
                            } else {
                                Text(String(Int(power)))
                                    .font(.title)
                                    .fontWeight(.black)
                                Text("Watts")
                                    .font(.body)
                            }
                        }
                        .foregroundColor(getColor(for: power))
                    } else {
                        Text("Offline")
                            .font(.body)
                            .foregroundStyle(Color.gray)
                    }
                } else {
                    ProgressView().scaleEffect(0.8)
                }
                
                
                
                
            }
            .frame(width: geometry.size.width, height: geometry.size.width / 2)
        }
        .frame(height: 150) // Adjust the height for the semi-circle
        .padding()
        
        loadReadingDetailView()
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
    
    func loadReadingDetailView() -> some View {
        return HStack(alignment: .top, spacing: 10) {
            VStack {
                HStack {
                    Label(" Units", systemImage: "powermeter")
                    Spacer()
                    isRightDevice ? Text(String(reading.energy)) + Text(" kWh") : Text("-")
                    
                }
                HStack {
                    Label(" Voltage", systemImage: "powerplug.portrait")
                    Spacer()
                    isRightDevice ? Text(String(reading.voltage)) + Text(" Volts") : Text("-")
                }
                HStack {
                    Label("Current", systemImage: "alternatingcurrent")
                    Spacer()
                    isRightDevice ? Text(String(reading.current)) + Text(" Amp") : Text("-")
                }
                HStack {
                    Label(" Nominal", systemImage: "lessthanorequalto.circle")
                    Spacer()
                    isRightDevice ? Text(String(minValue)) + Text(" W") : Text("-")
                }
            }
            
            Spacer()
            
            VStack {
                HStack {
                    Label(" Frequency", systemImage: "waveform")
                    Spacer()
                    isRightDevice ? Text(String(reading.frequency)) + Text(" Hz") : Text("-")
                }
                HStack {
                    Label("Power Factor", systemImage: "angle")
                    Spacer()
                    isRightDevice ? Text(String(reading.pf)) : Text("-")
                }
                HStack {
                    Label(" Usage", systemImage: "leaf.circle")
                    Spacer()
                    isRightDevice ? Text(String(reading.level)) : Text("-")
                }
                HStack {
                    Label(" Alarm", systemImage: "greaterthanorequalto.circle")
                    Spacer()
                    isRightDevice ? Text(String(maxValue)) + Text(" W") : Text("-")
                }
            }
            
        }
        .font(.footnote)
        .frame(maxWidth: .infinity)
        .padding()
    }
}

