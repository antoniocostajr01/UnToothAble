//
//  GameManager.swift
//  UnToothAble
//
//  Created by Antonio Costa on 14/03/26.
//

import Foundation
import SwiftUI
import SpriteKit
import Observation

@Observable
@MainActor
class GameManager {

    var currentScene: GameDelegator = .home
        
    var gameSpeed: CGFloat = 250
    
    var lastScore: Int = 0
    
    var hasSawHistory: Bool {
        get {
            UserDefaults.standard.bool(forKey: "hasSeenHistory")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "hasSeenHistory")
        }
    }

    var restartRun: () -> Void = {}
    var continueRun: () -> Void = {}

    var hasUsedReviveThisRun = false
    var isRewardedAdReady = false
    var isShowingRewardedAd = false

    let gameScene: GameScene = {
        let scene = GameScene()
        scene.scaleMode = .resizeFill
        return scene
    }()

    func goToScene(_ scene: GameDelegator) {
        currentScene = scene
    }

    var canUseContinue: Bool {
        !hasUsedReviveThisRun && isRewardedAdReady && !isShowingRewardedAd
    }

    func refreshRewardedAvailability() {
        isRewardedAdReady = RewardedAdManager.shared.isAdReady
    }

    func resetReviveForNewRun() {
        hasUsedReviveThisRun = false
        refreshRewardedAvailability()
    }

    func markReviveAsUsed() {
        hasUsedReviveThisRun = true
        isRewardedAdReady = false
    }
}
