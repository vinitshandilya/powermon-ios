import SwiftUI

class NavigationManager: ObservableObject {
    @Published var lastVisitedView: String = "Root"
    @Published var navigationPath: NavigationPath = NavigationPath()
}
