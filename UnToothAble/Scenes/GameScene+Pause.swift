//
//  GameScene+Pause.swift
//  UnToothAble
//
//  Created by Antonio Costa on 15/03/26.
//

import SpriteKit

extension GameScene {
    func pauseGame() {
        isPaused = true
        view?.isPaused = true
    }

    func resumeGame() {
        lastUpdateTime = 0
        view?.isPaused = false
        isPaused = false
    }
}
