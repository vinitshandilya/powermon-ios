//
//  ResetButton.swift
//  Powermon
//
//  Created by vshandil on 24/09/22.
//

import Foundation
import SwiftUI

struct ResetButton: View {
    var mqttmgr: MQTTManager
    @State private var isPresentingConfirm: Bool = false
    
    var body: some View {
        Button("Reset", role: .destructive) {
            isPresentingConfirm = true
        }
        .confirmationDialog("Are you sure?", isPresented: $isPresentingConfirm) {
            // publishing "1" on intopic will reset the module
            Button("Reset usage?", role: .destructive) { mqttmgr.sendMessage(topic: "intopic", message: "1")}
        }
        message: {
            Text("Accumulated usage will be reset. You cannot undo this")
        }
    }
}
