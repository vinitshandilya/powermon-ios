import SwiftUI

struct AnalyticsTab: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var isSeeMoreSheetShowing: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
//            OutlineButton().onTapGesture { isSeeMoreSheetShowing = true }
//            Spacer()
            
            
            
        }
        .sheet(isPresented: $isSeeMoreSheetShowing) {
            SeeMore()
        }
        .onAppear {
            navigationManager.lastVisitedView = "AnalyticsTab"
        }
    }
}
