import SwiftUI

struct TabItem: View {
    let text: String
    let icon: String
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Image(systemName: icon)
            Text(text)
                .font(.footnote)
        }
        .padding()
    }
}
