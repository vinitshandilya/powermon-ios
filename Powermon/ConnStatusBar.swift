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
        case "connected":
            return Text(status)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: 30, alignment: .trailing)
                .foregroundColor(.white)
                .background(Color("ConnectedColor"))
        case "offline":
            return Text(status)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: 30, alignment: .trailing)
                .foregroundColor(.white)
                .background(Color("DisconnectedColor"))
        default:
            return Text("unknown")
                .padding()
                .frame(maxWidth: .infinity, maxHeight: 30, alignment: .trailing)
                .foregroundColor(.white)
                .background(Color.gray)
        }
    }
}

struct ConnStatusBar_Previews: PreviewProvider {
    static var previews: some View {
        ConnStatusBar(status: "unknown")
    }
}
