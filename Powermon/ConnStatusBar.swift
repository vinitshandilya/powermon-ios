//
//  ConnStatusBar.swift
//  Powermon
//
//  Created by vshandil on 24/09/22.
//

import SwiftUI

struct ConnStatusBar: View {
    var status: String
    var body: some View {
        
        switch status {
        case "low":
            return Text("Nominal usage")
                .font(.footnote)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: 30, alignment: .leading)
                .foregroundColor(.white)
                .background(Color("ConnectedColor"))
            
        case "moderate":
            return Text("Moderate usage")
                .font(.footnote)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: 30, alignment: .leading)
                .foregroundColor(.white)
                .background(Color("ModerateColor"))
            
        case "high":
            return Text("Higher than usual consumption")
                .font(.footnote)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: 30, alignment: .leading)
                .foregroundColor(.white)
                .background(Color("HighUsageColor"))
            
        case "unknown":
            return Text("")
                .font(.footnote)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: 30, alignment: .leading)
                .foregroundColor(.white)
                .background(Color("UnknownColor"))
            
        default:
            return Text("Unknown")
                .font(.footnote)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: 30, alignment: .leading)
                .foregroundColor(.white)
                .background(Color("UnknownColor"))
        }
    }
}

struct ConnStatusBar_Previews: PreviewProvider {
    static var previews: some View {
        ConnStatusBar(status: "unknown")
    }
}
