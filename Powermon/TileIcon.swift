//
//  TileIcon.swift
//  Powermon
//
//  Created by vshandil on 12/01/25.
//

import SwiftUI

struct TileIcon: View {
    let error: Bool
    var body: some View {
        if error {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "bolt.circle.fill")
                    .foregroundColor(.blue.opacity(0.5))
                    .font(.system(size: 30))
                Image(systemName: "exclamationmark.circle.fill")
                    .renderingMode(.original)
                    .resizable()
                    .frame(width: 10, height: 10) // Small red badge
                    .offset(x: 2, y: -2)
            }
        } else {
            Image(systemName: "bolt.circle.fill")
                .renderingMode(.original)
                .font(.system(size: 30))
        }
        
    }
}


#Preview {
    TileIcon(error: true)
}
