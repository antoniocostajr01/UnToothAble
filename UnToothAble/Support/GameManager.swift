//
//  GameManager.swift
//  UnToothAble
//
//  Created by Antonio Costa on 14/03/26.
//

import Foundation
import SwiftUI
import SpriteKit

@Observable
class GameManager {

    var currentScene: GameDelegator = .home

    var lastScore: Int = 0

    var restartRun: () -> Void = {}
    var continueRun: () -> Void = {}

    let gameScene: GameScene = {
        let scene = GameScene()
        scene.scaleMode = .resizeFill
        return scene
    }()

    func goToScene(_ scene: GameDelegator) {
        currentScene = scene
    }
}
