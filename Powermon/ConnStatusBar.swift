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
        case "nominal":
            return Text(status)
                .font(.footnote)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: 30, alignment: .trailing)
                .foregroundColor(.white)
                .background(Color("ConnectedColor"))
        case "offline":
            return Text(status)
                .font(.footnote)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: 30, alignment: .trailing)
                .foregroundColor(.white)
                .background(Color("DisconnectedColor"))
        case "highusage":
            return Text("Higher than usual consumption")
                .font(.footnote)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: 30, alignment: .trailing)
                .foregroundColor(.white)
                .background(Color("HighUsageColor"))
        default:
            return Text("unknown")
                .font(.footnote)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: 30, alignment: .trailing)
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
