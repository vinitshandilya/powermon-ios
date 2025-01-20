import SwiftUI

class SnackBarManager: ObservableObject {
    @Published var isShowing: Bool = false
    @Published var message: String = ""

    func show(message: String, duration: TimeInterval = 3.0) {
        self.message = message
        withAnimation {
            self.isShowing = true
        }
        // Dismiss after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation {
                self.isShowing = false
            }
        }
    }
}

struct SnackBarView: View {
    @ObservedObject var manager: SnackBarManager

    var body: some View {
        if manager.isShowing {
            VStack {
                Spacer()
                Text(manager.message)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(8)
                    .padding(.horizontal, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            .animation(.easeInOut(duration: 0.3), value: manager.isShowing)
        }
    }
}
