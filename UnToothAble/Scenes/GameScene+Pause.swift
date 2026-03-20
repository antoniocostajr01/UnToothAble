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
    }

    func resumeGame() {
        isPaused = false
        lastUpdateTime = 0
    }
}
