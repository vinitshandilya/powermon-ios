import SwiftUI

struct AddNewDeviceButton: View {
    var body: some View {
        VStack {
            Text("+ Add New")
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5, 5])) // Dashed line
                .foregroundColor(Color("TileHeading"))
        )
    }
}
