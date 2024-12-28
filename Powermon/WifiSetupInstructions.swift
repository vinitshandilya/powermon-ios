//
//  ScratchPad 2.swift
//  Powermon
//
//  Created by vshandil on 27/12/24.
//

import Foundation
import SwiftUI

struct WifiSetupInstructions: View {
    @State var isESPReachable: Bool = false
    @State var espSearchTimedOut = false
    var body: some View {
            VStack(spacing: 20) {
                Image(systemName: "house.badge.wifi.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.primary)
                    .padding(.top, 40)
                
                HStack {
                    if isESPReachable {
                        LEDView(color: .green, blink: false)
                        Text("Device discovered!").font(.footnote)
                    } else if espSearchTimedOut {
                        LEDView(color: .blue, blink: false)
                        Text("No device found.").font(.footnote)
                    } else {
                        LEDView(color: .orange, blink: true)
                        Text("Searching for device. This may take upto 30 secs.").font(.footnote)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .center)

                // Heading
                Text("Setup your device")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                // Instructions text
                VStack(alignment: .leading, spacing: 10) {
                    
                    if !isESPReachable {
                        
                        HStack(alignment: .top, spacing: 10) {
                            Text("●")
                            Text("Tap the setup button on your device and wait until the LED stops blinking and glows continuously.")
                        }
                        HStack(alignment: .top, spacing: 10) {
                            Text("●")
                            Text("Connect to the device's access point - \"pzem_AP\". The default password is, \"12345678910\" (without quotes).")
                        }
                        
                        Button(action: openWiFiSettings) {
                            Text("Open Wi-Fi Settings")
                                .padding()
                                .background(Color("Tile3"))
                                .foregroundColor(.primary)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color("TileHeading"), lineWidth: 0.5)
                                )
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    HStack(alignment: .top, spacing: 10) {
                        Text("●")
                        Text("Save your WiFi network to the device")
                    }
                    HStack(alignment: .top, spacing: 10) {
                        Text("●")
                        Text("The device should blink shortly and connect to your home network.")
                    }
                }
                .font(.footnote)
                .multilineTextAlignment(.leading)

                // Additional instruction
                Text("To restart setup, switch the device back in setup mode and repeat.")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()
            }
            .padding()
            .onAppear(perform: testESPReachability)
        }
    
    func openWiFiSettings() {
        if let url = URL(string: "App-prefs:WIFI") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    func testESPReachability() {
        // Create a URL for the ESP module's web server
        guard let url = URL(string: "http://nodemcu.local") else {
            print("Invalid URL")
            isESPReachable = false
            return
        }
        
        // Create a URLSession configuration with a timeout
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10 // Timeout in seconds for the request
        config.timeoutIntervalForResource = 10 // Timeout for the entire resource
        
        let session = URLSession(configuration: config)
        
        // Create a URL session data task to check the connectivity
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                // Handle error (e.g., no network, unreachable, or timeout)
                if (error as NSError).code == NSURLErrorTimedOut {
                    print("Request timed out")
                    espSearchTimedOut = true
                } else {
                    print("Error: \(error.localizedDescription)")
                }
                isESPReachable = false
                return
            }
            
            // Check the HTTP response code
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print("ESP module is reachable!")
                    isESPReachable = true
                } else {
                    print("ESP module returned an error: \(httpResponse.statusCode)")
                    isESPReachable = false
                }
            }
        }
        task.resume()
    }
}
