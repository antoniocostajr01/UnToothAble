//
//  Game.swift
//  UnToothAble
//
//  Created by Antonio Costa on 15/03/26.
//

import SpriteKit
import SwiftUI

struct Game: View {

    @Environment(GameManager.self) var gameManager

    var body: some View {

        SpriteView(scene: gameManager.gameScene)
            .ignoresSafeArea()
            .onAppear {

                let scene = gameManager.gameScene

                scene.onGameOver = { score in
                    gameManager.lastScore = score
                    gameManager.goToScene(.gameOver)
                }

                gameManager.restartRun = {
                    scene.restartGame()
                }

                gameManager.continueRun = {
                    scene.continueRun()
                }

                GameCenterManager.shared.authenticate()
            }
    }
}
