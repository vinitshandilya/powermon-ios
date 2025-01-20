import SwiftUI

struct TileIcon: View {
    let status: String
    
    var body: some View {
        
        if status == "ok" {
            Image(systemName: "bolt.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 40))
                .frame(width: 60, height: 60)
                .background(.green.opacity(0.2))
                .clipShape(Circle())
        }
        
        if status == "pending" {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "bolt.circle.fill")
                    .foregroundColor(.gray.opacity(0.5))
                    .font(.system(size: 40))
                    .frame(width: 60, height: 60)
                    .background(.gray.opacity(0.2))
                    .clipShape(Circle())
                
                Image(systemName: "exclamationmark.circle.fill")
                    .resizable()
                    .foregroundColor(.orange)
                    .frame(width: 15, height: 15) // Small red badge
                    .offset(x: 2, y: -2)
            }
        }
        
        if status == "error" {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "bolt.circle.fill")
                    .foregroundColor(.gray.opacity(0.5))
                    .font(.system(size: 40))
                    .frame(width: 60, height: 60)
                    .background(.gray.opacity(0.2))
                    .clipShape(Circle())
                
                Image(systemName: "exclamationmark.circle.fill")
                    .resizable()
                    .foregroundColor(.red)
                    .frame(width: 15, height: 15) // Small red badge
                    .offset(x: 2, y: -2)
            }
        }
        
    }
}


#Preview {
    TileIcon(status: "ok")
}
