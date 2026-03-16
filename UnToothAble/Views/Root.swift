//
//  Root.swift
//  UnToothAble
//
//  Created by Antonio Costa on 15/03/26.
//

import SwiftUI

struct Root: View {
    
    @State private var gameManager = GameManager()
    
    var body: some View {
        ZStack {
            switch gameManager.currentScene {
            case .home:
                Home()
            case .settings:
                Settings()
            case .game:
                Game()
            }
        }
        .environment(gameManager)
    }
}

#Preview {
    Root()
}
