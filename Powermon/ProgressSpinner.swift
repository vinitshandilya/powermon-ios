import SwiftUI

struct ProgressSpinner: View {
    let progressText: String
    var body: some View {
        VStack(alignment: .center) {
            ProgressView().scaleEffect(0.8)
            Text(progressText).font(.footnote)
                .multilineTextAlignment(.center)
        }
        .foregroundColor(.gray)
        .padding(.horizontal, 100)
    }
}

#Preview {
    ProgressSpinner(progressText: "Getting devices from cloud. This may take up to a minute.")
}
