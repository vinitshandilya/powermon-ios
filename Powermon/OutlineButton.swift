import SwiftUI

struct OutlineButton: View {
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "chart.bar.yaxis")
                .font(.title)
                .padding(.trailing)
                .foregroundColor(.red)
                .fontWeight(.light)
            VStack(alignment: .leading) {
                HStack(alignment: .center, spacing: 5) {
                    Text("Estimated power bill:")
                        .font(.footnote)
                        .fontWeight(.bold)
                    
                    Text("₹ 2046.05")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                HStack(alignment: .center, spacing: 5) {
                    Text("13.3%")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    Text("higher than last month")
                        .font(.caption)
                }
            }
            Spacer()
            Image(systemName: "chevron.down")
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(.red)
        }
        .foregroundColor(.gray)
        .padding(.all, 15)
        .frame(maxWidth: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.gray, lineWidth: 0.3)  // Grey border
        )
        .padding([.leading, .trailing])  // Padding on sides
    }
}
