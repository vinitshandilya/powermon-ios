import SwiftUI

struct ChartSelectorTabs: View {
    @Namespace private var animationNamespace
    @Binding var selectedChart: String
    
    var body: some View {
            HStack {
                ForEach(["Hour", "Day", "Week", "Month"], id: \.self) { label in
                    
                    let markerWidth = CGFloat(UIScreen.main.bounds.width / 4 - 20)
                    
                    VStack(alignment: .center, spacing: 0) {
                        Text(label)
                            .lineLimit(1)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .scaleEffect(selectedChart == label ? 1.1 : 1.0)
                            .animation(.spring(response: 0.5, dampingFraction: 1), value: selectedChart)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 1)) {
                                    selectedChart = label
                                }
                            }
                        
                        if selectedChart == label {
                            Rectangle()
                                .frame(width: markerWidth, height: 2)
                                .foregroundColor(.primary)
                                .matchedGeometryEffect(id: "marker", in: animationNamespace)
                        } else {
                            Spacer()
                                .frame(width: markerWidth, height: 2)
                        }
                    }
                }
            }
            .font(.footnote)
            .padding(.all, 10)
        }

}
