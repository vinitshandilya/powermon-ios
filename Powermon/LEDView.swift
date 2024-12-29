//
//  LEDView.swift
//  Powermon
//
//  Created by vshandil on 27/12/24.
//

import SwiftUI

import SwiftUI

struct LEDView: View {
    let color: Color
    let blink: Bool
    @State private var isBlinking = false
    
    var body: some View {
        
        if blink {
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
                .opacity(isBlinking ? 1 : 0) // Completely transparent in the off state
                .shadow(color: color.opacity(isBlinking ? 1 : 0), radius: 40, x: 0, y: 0) // Glow matches the blink
                .overlay(Circle().stroke(color, lineWidth: 0.2)) // Optional border for consistent outline
                .onAppear {
                    withAnimation(Animation.linear(duration: 0.5).repeatForever(autoreverses: true)) {
                        isBlinking.toggle() // Trigger blinking animation
                    }
                }
                .padding(.trailing, 5)
        } else {
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
                .shadow(color: color.opacity(0.5), radius: 10, x: 0, y: 0) // Glowing effect
                .overlay(Circle().stroke(color, lineWidth: 4))
                .padding(.trailing, 5)
        }
        
        
    }
}

struct LEDView_Previews: PreviewProvider {
    static var previews: some View {
        LEDView(color: .red, blink: true)
    }
}
