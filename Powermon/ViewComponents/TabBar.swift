//
//  TabBar.swift
//  Powermon
//
//  Created by vshandil on 15/01/25.
//

import SwiftUI

struct TabBar: View {
    @Binding var selectedTab: String
    
    var body: some View {
        HStack {
            TabItem(text: "Home", icon: "house", isSelected: selectedTab == "Home")
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = "Home"
                    }
                }
            TabItem(text: "Automate", icon: "sparkles", isSelected: selectedTab == "Automations")
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = "Automations"
                    }
                }
            TabItem(text: "Analytics", icon: "chart.bar.xaxis", isSelected: selectedTab == "Analytics")
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = "Analytics"
                    }
                }
            TabItem(text: "Settings", icon: "gearshape", isSelected: selectedTab == "Settings")
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = "Settings"
                    }
                }
        }
        .frame(maxWidth: .infinity)
//        .background(.gray.opacity(0.05))
        .edgesIgnoringSafeArea(.all)
    }
}

