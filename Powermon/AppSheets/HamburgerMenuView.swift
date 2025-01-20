//
//  HamburgerMenuView.swift
//  Powermon
//
//  Created by vshandil on 17/01/25.
//

import SwiftUI

struct HamburgerMenuView: View {
    let onLogout: () -> Void
    
    var body: some View {
        List {
            Button(action: {
                print("About Us tapped")
            }) {
                Label("About Us", systemImage: "info.circle")
                    .foregroundColor(.primary)
            }.listRowSeparator(.hidden)
            
            Button(action: {
                onLogout()
            }) {
                Label("Logout", systemImage: "arrow.right.circle")
                    .foregroundColor(.red)
            }.listRowSeparator(.hidden)
        }
        .font(.footnote)
        .fontWeight(.bold)
        .listStyle(.plain)
        .padding(.top)
    }
}
