import SwiftUI

struct TabItem: View {
    let text: String
    let icon: String
    var isSelected: Bool
    
    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: icon)
                .padding()
                .background(isSelected ? Color.green.opacity(0.4) : Color.gray.opacity(0.1))
                .clipShape(Circle())
            
            Text(text).font(.caption2)
            
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 5)
        
    }
}
