//
//  GameScene+Pause.swift
//  UnToothAble
//
//  Created by Antonio Costa on 15/03/26.
//

import SpriteKit

extension GameScene {
    func pauseGame() {
        guard !isGameOver else { return }
        isPaused = true
        view?.isPaused = true
        physicsWorld.speed = 0
    }

    func resumeGame() {
        guard !isGameOver else { return }

        physicsWorld.speed = 0
        view?.isPaused = false
        isPaused = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            guard let self = self, !self.isGameOver else { return }
            self.lastUpdateTime = 0
            self.skipNextFrame = true
            self.physicsWorld.speed = 1
        }
    }
}
