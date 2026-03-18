//
//  Shop.swift
//  UnToothAble
//
//  Created by sofia leitao on 17/03/26.
//
import SwiftUI

struct Shop: View {
    @Environment(GameManager.self) var gameManager
    
    var body: some View {
        Button {
            gameManager.goToScene(.home)
        } label: {
            Text("go back to home")
                .foregroundStyle(.white)
                .font(.system(size: 60))
        }
    }
}

#Preview {
    Shop()
}
