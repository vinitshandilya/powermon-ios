//
//  EmptyDeviceView.swift
//  Powermon
//
//  Created by vshandil on 16/01/25.
//

import SwiftUI

struct EmptyDeviceView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40, weight: .bold))
            
            Text("No devices found. Tap the '+' button to add new.")
                .multilineTextAlignment(.center)
        }
        .padding(.all, 80)
        
    }
}

#Preview {
    EmptyDeviceView()
}
