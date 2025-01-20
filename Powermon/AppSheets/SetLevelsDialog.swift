import SwiftUI

struct SetLevelsDialog: View {
    @Binding var nominalUsage: Double
    @Binding var maximumUsage: Double
    var onSave: (Double, Double) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("You can set the nominal and high usage levels for your device. An alarm will sound when the watt usage exceeds the alarm level.")
                
                // Slider for Maximum Usage
                VStack(alignment: .leading) {
                    Text("Alarm Threshold: \(Int(maximumUsage))")
                    Slider(value: $maximumUsage, in: 100...10000, step: 50)
                }
                .padding(.top, 20)
                .foregroundColor(.gray)
                
                // Slider for Nominal Usage
                VStack(alignment: .leading) {
                    Text("Nominal threshold: \(Int(nominalUsage))")
                    Slider(value: $nominalUsage, in: 50...min(maximumUsage, 1000), step: 10)
                }
                .foregroundColor(.gray)
                
                // Save Button with Validation
                HStack {
                    Spacer()
                    Button("Save") {
                        if nominalUsage <= maximumUsage {
                            onSave(nominalUsage, maximumUsage)
                            dismiss()
                        } else {
                            print("Nominal Usage cannot be greater than Maximum Usage")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Spacer()
            }
            .navigationTitle("Set Levels")
            .navigationBarItems(trailing: Button("Cancel") { dismiss() })
            .padding()
        }
    }
}
