//
//  GameManager.swift
//  UnToothAble
//
//  Created by Antonio Costa on 14/03/26.
//

import Foundation
import SwiftUI

@Observable
class GameManager {
    var currentScene: GameDelegator = .home
    
    var nextScene: GameDelegator = .home
    
    var gameSpeed: CGFloat = 250
    
    func goToScene(_ scene: GameDelegator) {
        currentScene = scene
    }
}
