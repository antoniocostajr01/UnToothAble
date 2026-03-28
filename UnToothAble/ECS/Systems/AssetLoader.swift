//
//  AssetLoader.swift
//  UnToothAble
//
//  Created by Antonio Costa on 24/03/26.
//

import Foundation
import SpriteKit

final class AssetLoader {
        
    static func preload(completion: @escaping () -> Void = {} ) {
        
        let textureNames = [
            // Backgrounds
            "Scene1", "Scene2", "Scene3", "Scene4", "Scene5",
            "Scene6", "Scene7", "Scene8", "Scene9", "Scene10",
            
            // Player
            GameConstants.Assets.playerFrame1,
            GameConstants.Assets.playerFrame2,
            GameConstants.Assets.playerFrame3,
            GameConstants.Assets.playerFrame4,
            GameConstants.Assets.playerFrame5,
            
            // Boss
            GameConstants.Assets.bossFrame1,
            GameConstants.Assets.bossFrame2,
            GameConstants.Assets.fairyAttack,

            // Obstacles
            GameConstants.Assets.phase1ObstacleFrame1,
            GameConstants.Assets.phase1ObstacleFrame2,
            GameConstants.Assets.phase2ObstacleFrame1,
            GameConstants.Assets.phase2ObstacleFrame2,
            GameConstants.Assets.phase3ObstacleFrame1,
            GameConstants.Assets.phase3ObstacleFrame2,
            GameConstants.Assets.phase4ObstacleFrame1,
            GameConstants.Assets.phase4ObstacleFrame2,
            GameConstants.Assets.flyingObstacleFrame1,
            GameConstants.Assets.flyingObstacleFrame1
        ]
        
        let textures = textureNames.map { SKTexture(imageNamed: $0) }
        
        SKTexture.preload(textures) {
            completion()
        }
    }
}
