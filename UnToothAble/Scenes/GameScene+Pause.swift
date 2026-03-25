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
    }

    func resumeGame() {
        guard !isGameOver else { return }
        lastUpdateTime = 0
        view?.isPaused = false
        isPaused = false
    }
}
