import SwiftUI

struct DeviceButtonTile: View {
    let user_id: String = UserDefaults.standard.string(forKey: "user_id") ?? ""
    let device: Device
    @Binding var editingDeviceID: String?
    @Binding var newDeviceName: String
    @FocusState private var isTextFieldFocused: Bool
    @State var mqttmanager: MQTTManager
    @State var updateDeviceName: (String, String, String) -> Void
    @State var deleteDeviceFromServer: (String, Device) -> Void
    
    var isRightDevice: Bool {
        return (device.device_id == mqttmanager.reading.device_id)
    }
    
    var tileBgColor: Color {
        mqttmanager.isMqttConnected && mqttmanager.isMqttSubscribed && isRightDevice ?
        Color.clear : Color.clear
    }
    
    var tileTextColor: Color {
        mqttmanager.isMqttConnected && mqttmanager.isMqttSubscribed && isRightDevice ?
        Color.primary : Color.primary
    }

    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            // Icon and menu
            HStack(alignment: .top, spacing: 10) {
                if mqttmanager.isMqttConnected && mqttmanager.isMqttSubscribed {
                    
                    if mqttmanager.hasReceivedMessage {
                        if isRightDevice {
                            TileIcon(status: "ok")
                        } else {
                            TileIcon(status: "error")
                        }
                    } else {
                        TileIcon(status: "pending")
                    }

                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle()) // Ensure it's a circular style
                        .scaleEffect(1.0)
                        .frame(width: 40, height: 40)
                }
                
                Spacer()
                
                Menu {
                    Button(action: {
                        editingDeviceID = device.device_id
                        newDeviceName = device.device_name
                        isTextFieldFocused = true
                    }) {
                        Label("Rename", systemImage: "pencil")
                    }
                    Button(role: .destructive, action: {
                        deleteDeviceFromServer(user_id, device)
                    }) {
                        Label("Delete", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(tileTextColor)
                        .fontWeight(.bold)
                        .rotationEffect(.degrees(90))
                        .padding(.all, 8)
                        .contentShape(Rectangle())
                }
                
            }
            
            // Names
            VStack(alignment: .leading, spacing: 5) {
                // Meter name
                if editingDeviceID == device.device_id {
                    TextField("Enter new name", text: $newDeviceName, onCommit: {
                        if newDeviceName != device.device_name {
                            updateDeviceName(user_id, device.device_id, newDeviceName)
                        }
                        editingDeviceID = nil
                        isTextFieldFocused = false
                    })
                    .focused($isTextFieldFocused)
                    .font(.footnote)
                    .background(Color.clear)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .onTapGesture {
                        if newDeviceName.isEmpty {
                            newDeviceName = device.device_name
                        }
                    }
                } else {
                    Text(device.device_name)
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(tileTextColor)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .multilineTextAlignment(.leading)
                }
                
                if mqttmanager.hasReceivedMessage {
                    if isRightDevice {
                        Text("This month: \(String(format: "%.0f", mqttmanager.reading.power)) Watts")
                            .font(.caption)
                            .foregroundColor(tileTextColor)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .multilineTextAlignment(.leading)
                    } else {
                        Text("Not responding")
                            .font(.caption)
                            .foregroundColor(tileTextColor)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .multilineTextAlignment(.leading)
                    }
                } else {
                    Text("Waiting")
                        .font(.caption)
                        .foregroundColor(tileTextColor)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.leading, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Card(bgColor: Color.gray.opacity(0.1)))
        .onChange(of: mqttmanager.isMqttConnected) { isconnected in
            print("DeviceTile: MQTT connection changed to \(isconnected)")
        }
        .onChange(of: mqttmanager.isMqttSubscribed) { issubscribed in
            print("DeviceTile: MQTT subscription changed to \(issubscribed)")
        }
    }
        
}

