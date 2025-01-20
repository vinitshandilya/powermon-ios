import SwiftUI

struct ProgressSpinner: View {
    let progressText: String
    var body: some View {
        VStack(alignment: .center) {
            ProgressView().scaleEffect(0.8).padding(.bottom, 11)
            Text(progressText).font(.footnote)
                .multilineTextAlignment(.center)
        }
        .foregroundColor(.gray)
        .frame(width: 200, height: 100, alignment: .center)
        .padding()
    }
}

#Preview {
    ProgressSpinner(progressText: "Getting devices from cloud. This may take up to a minute.")
}
