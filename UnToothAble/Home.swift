//
//  Home.swift
//  UnToothAble
//
//  Created by Antonio Costa on 13/03/26.
//

import SwiftUI

struct Home: View {
    var body: some View {
        
        Text("UnToothAble")
            .foregroundStyle(.red)
            .font(.system(size: 80))
        
        
        Button {
            //todo: Começar jogo
        } label: {
            Text("Play")
                .foregroundStyle(.black)
                .font(.system(size: 60))
        }

    }
}

#Preview {
    Home()
}
