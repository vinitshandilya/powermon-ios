import SwiftUI

struct DeviceButtonTile: View {
    let device: Device
    @Binding var editingDeviceID: String?
    @Binding var newDeviceName: String
    @FocusState private var isTextFieldFocused: Bool
    let mqttmanager: MQTTManager
    let updateDeviceName: (String, String) -> Void
    let deleteDeviceFromServer: (Device) -> Void
    
    var tileBgColor: Color {
        mqttmanager.isMqttConnected && mqttmanager.isMqttSubscribed && (device.device_id == mqttmanager.reading.device_id) ?
        Color("CardBgActive") : Color("CardBgDefault")
    }
    
    var tileTextColor: Color {
        mqttmanager.isMqttConnected && mqttmanager.isMqttSubscribed && (device.device_id == mqttmanager.reading.device_id) ?
        Color("CardTextActive") : Color("CardTextDefault")
    }

    var body: some View {
        HStack(alignment: .center) {
            // Tile Icon
            HStack(alignment: .center, spacing: 10) {
                if mqttmanager.isMqttConnected && mqttmanager.isMqttSubscribed {
                    if device.device_id == mqttmanager.reading.device_id {
                        TileIcon(error: false)
                            
                    } else {
                        TileIcon(error: true)
                    }
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle()) // Ensure it's a circular style
                        .scaleEffect(1.0) // Maintain default size
                        .frame(width: 30, height: 30)
                }
                
                // Tile Text
                if editingDeviceID == device.device_id {
                    TextField("Enter new name", text: $newDeviceName, onCommit: {
                        if newDeviceName != device.device_name {
                            updateDeviceName(device.device_id, newDeviceName)
                        }
                        editingDeviceID = nil
                        isTextFieldFocused = false
                    })
                    .focused($isTextFieldFocused)
                    .font(.body)
                    .background(Color.clear)
                    .foregroundColor(.primary)
                    .onTapGesture {
                        if newDeviceName.isEmpty {
                            newDeviceName = device.device_name
                        }
                    }
                } else {
                    Text(device.device_name)
                        .font(.footnote)
                        .foregroundColor(tileTextColor)
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .multilineTextAlignment(.leading)
                }
                
                
            }
            
            Spacer()
            
            // Tile Menu
            Menu {
                Button(action: {
                    editingDeviceID = device.device_id
                    newDeviceName = device.device_name
                    isTextFieldFocused = true
                }) {
                    Label("Rename", systemImage: "pencil")
                }
                Button(role: .destructive, action: {
                    deleteDeviceFromServer(device)
                }) {
                    Label("Delete", systemImage: "trash")
                        .foregroundColor(.red)
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(tileTextColor)
                    .fontWeight(.bold)
                    .rotationEffect(.degrees(90))
                    .padding(.all, 10)
                    .contentShape(Rectangle())
            }
        }
        .padding(.vertical, 16)
        .padding(.leading, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Card(bgColor: tileBgColor))
    }
        
}

