import SwiftUI

struct AnalyticsTab: View {
    var body: some View {
        NavigationView {
            Text("Analytics")
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Analytics").font(.headline)
                    }
                }
        }
        .tabItem {
            TabItem(text: "Analytics", icon: "chart.bar.xaxis")
        }
    }
}
