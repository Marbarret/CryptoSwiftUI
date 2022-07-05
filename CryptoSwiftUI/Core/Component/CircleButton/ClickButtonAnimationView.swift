//
//  ClickButtonAnimationView.swift
//  CryptoSwiftUI
//
//  Created by Marcylene Barreto on 21/06/22.
//

import SwiftUI

struct ClickButtonAnimationView: View {
    @Binding var animation: Bool
    
    var body: some View {
        Circle()
            .stroke(lineWidth: 5.0)
            .scale(animation ? 1.0 : 0.0)
            .opacity(animation ? 0.0 : 1.0)
            .animation(animation ? Animation.easeOut(duration: 1.0) : .none)
            
    }
}

struct ClickButtonAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        ClickButtonAnimationView(animation: .constant(false))
            .foregroundColor(.red)
            .frame(width: 100, height: 100)
    }
}
