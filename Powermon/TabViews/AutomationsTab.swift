import SwiftUI

struct AutomationsTab: View {
    @EnvironmentObject var navigationManager: NavigationManager
    var body: some View {
        VStack {
            
        }
        .onAppear {
            navigationManager.lastVisitedView = "AutomationsTab"
        }
    }
}
