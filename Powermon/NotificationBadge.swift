//
//  NotificationBadge.swift
//  Powermon
//
//  Created by vshandil on 05/01/25.
//

import SwiftUI

struct NotificationBadge: View {
    let active: Bool
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: "bell.fill")
                .font(.system(size: 12))
                .foregroundColor(.primary)
            if active {
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8) // Small red badge
                    .offset(x: 3, y: -3)
            }
        }
    }
}

#Preview {
    NotificationBadge(active: true)
}
