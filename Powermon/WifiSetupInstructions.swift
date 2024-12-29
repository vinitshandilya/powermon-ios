import Foundation
import SwiftUI

struct WifiSetupInstructions: View {
    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top, spacing: 10) {
                Text("●")
                Text("A new device is created in cloud!")
                    .multilineTextAlignment(.leading)
            }
            HStack(alignment: .top, spacing: 10) {
                Text("●")
                Text("Tap the Setup button on device and wait until the LED glows solid blue.")
                    .multilineTextAlignment(.leading)
            }
            HStack(alignment: .top, spacing: 10) {
                Text("●")
                Text("Connect to the device's access point - \"pzem_AP\". The default password is, \"12345678910\" (without quotes), and follow rest of instructions.")
                    .multilineTextAlignment(.leading)
            }
            Button(action: openWiFiSettings) {
                Text("Open Wi-Fi Settings")
                    .padding()
                    .background(Color("Tile3"))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("TileHeading"), lineWidth: 0.5))
            }.frame(maxWidth: .infinity, alignment: .center)
            
            Text("To restart setup, switch the device back in setup mode and repeat.")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.horizontal)

            Spacer()
            }
            .padding()
            .font(.footnote)
        }
    
    func openWiFiSettings() {
        if let url = URL(string: "App-prefs:WIFI") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
}
