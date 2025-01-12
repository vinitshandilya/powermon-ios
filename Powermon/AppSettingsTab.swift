import SwiftUI

struct AppSettingsTab: View {
    var body: some View {
        NavigationView {
            Text("Settings")
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Settings").font(.headline)
                    }
                }
        }
        .tabItem {
            TabItem(text: "Settings", icon: "gearshape")
        }
    }
}
