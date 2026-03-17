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
            
            if gameManager.currentScene == .home {
                Home()
            }
            
            if gameManager.currentScene == .settings {
                Settings()
            }
            
            if gameManager.currentScene == .game || gameManager.currentScene == .gameOver {
                Game()
            }
            
            if gameManager.currentScene == .gameOver {
                GameOver(
                    score: gameManager.lastScore,
                    onRestart: gameManager.restartRun,
                    onContinue: gameManager.continueRun
                )
            }
        }
        .environment(gameManager)
    }
}

#Preview {
    Root()
}
