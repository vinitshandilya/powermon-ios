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
                .frame(maxWidth: .infinity, maxHeight: 30)
                .foregroundColor(.white)
                .background(.green)
        case "offline":
            return Text(status)
                .frame(maxWidth: .infinity, maxHeight: 30)
                .foregroundColor(.white)
                .background(.red)
        default:
            return Text("unknown")
                .frame(maxWidth: .infinity, maxHeight: 30)
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
