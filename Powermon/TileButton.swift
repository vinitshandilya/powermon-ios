//
//  TileButtonTest.swift
//  Powermon
//
//  Created by vshandil on 15/01/25.
//

import SwiftUI

struct TileButton: View {
    let device: Device
    @Binding var editingDeviceID: String?
    @Binding var newDeviceName: String
    @FocusState private var isTextFieldFocused: Bool
    let mqttmanager: MQTTManager
    let updateDeviceName: (String, String) -> Void
    let deleteDeviceFromServer: (Device) -> Void
    
    var tileBgColor: Color {
        mqttmanager.isMqttConnected && mqttmanager.isMqttSubscribed && (device.device_id == mqttmanager.reading.device_id) ?
        Color("CardBgActive") : Color("TabHighlight")
    }
    
    var tileTextColor: Color {
        mqttmanager.isMqttConnected && mqttmanager.isMqttSubscribed && (device.device_id == mqttmanager.reading.device_id) ?
        Color("CardTextActive") : Color("CardTextDefault")
    }
    
    var iconColor: Color {
        mqttmanager.isMqttConnected && mqttmanager.isMqttSubscribed && (device.device_id == mqttmanager.reading.device_id) ?
        Color.green : Color.red
    }
    
    
    var body: some View {
        HStack(alignment: .center) {
            HStack {
                Image(systemName: "bolt.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(iconColor)
                    .padding()
                    .background(iconColor.opacity(0.2))
                    .clipShape(Circle())
                
                
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
                    VStack(alignment: .leading, spacing: 5) {
                        Text(device.device_name)
                            .font(.footnote)
                            .foregroundColor(tileTextColor)
                            .lineLimit(2)
                            .truncationMode(.tail)
                            .multilineTextAlignment(.leading)
                        
                        Text("UNITS: 191 Units")
                            .font(.footnote)
                            .foregroundColor(.black)
                    }
                }
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
        .foregroundColor(.gray)
        .padding(.all, 15)
        .frame(maxWidth: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.gray, lineWidth: 0.3)  // Grey border
        )
        .padding([.leading, .trailing])
    }
}
