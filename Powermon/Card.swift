import SwiftUI

struct Card: View {
    let bgColor: Color
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(bgColor)
//            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
    }
}
