import SwiftUI

struct SimpleTabView: View {
    @State private var swipeDirection = "None"
    var body: some View {
        VStack {
            Text("Swipe Direction: \(swipeDirection)")
                .font(.headline)
                .padding()
            
            Rectangle()
                .fill(Color.blue)
                .frame(width: 200, height: 200)
                .cornerRadius(12)
                .overlay(
                    Text("Swipe Me!")
                        .foregroundColor(.white)
                        .font(.title)
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let horizontalAmount = value.translation.width
                            
                            // Detect swipe direction based on horizontal drag
                            if horizontalAmount > 0 {
                                swipeDirection = "Swiped Right"
                            } else {
                                swipeDirection = "Swiped Left"
                            }
                        }
                        .onEnded { _ in
                            // Reset swipe direction when gesture ends
                            swipeDirection = "None"
                        }
                )
                .padding()
        }
    }
}


#Preview {
    SimpleTabView()
}
