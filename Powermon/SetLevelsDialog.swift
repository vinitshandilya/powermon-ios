import SwiftUI

struct SetLevelsDialog: View {
    @Binding var nominalUsage: Double
    @Binding var maximumUsage: Double
    var onSave: (Double, Double) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                // Slider for Maximum Usage
                VStack(alignment: .leading) {
                    Text("Maximum Usage: \(Int(maximumUsage))")
                    Slider(value: $maximumUsage, in: 100...10000, step: 50)
                }
                .padding()
                
                // Slider for Nominal Usage
                VStack(alignment: .leading) {
                    Text("Nominal Usage: \(Int(nominalUsage))")
                    Slider(value: $nominalUsage, in: 50...min(maximumUsage, 1000), step: 10)
                }
                .padding()
                
                // Save Button with Validation
                Button("Save") {
                    if nominalUsage <= maximumUsage {
                        onSave(nominalUsage, maximumUsage)
                        dismiss()
                    } else {
                        print("Nominal Usage cannot be greater than Maximum Usage")
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .navigationTitle("Set Levels")
            .navigationBarItems(trailing: Button("Cancel") { dismiss() })
        }
    }
}