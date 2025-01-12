import SwiftUI

struct AutomationsTab: View {
    var body: some View {
        NavigationView {
            Text("Automations")
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Automations").font(.headline)
                    }
                }
        }
        .tabItem {
            TabItem(text: "Automations", icon: "sparkle")
        }
    }
}
