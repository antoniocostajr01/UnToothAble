//
//  GameConstants.swift
//  UnToothAble
//
//  Central place for game configuration and magic numbers.
//

import CoreGraphics

enum GameConstants {
    
    // MARK: - Physics
    enum Physics {
        static let gravityY: CGFloat = -15
        static let scenarioSpeed: CGFloat = 300
        static let speedIncrement: CGFloat = 100
    }
    
    // MARK: - Physics categories (bitmasks)
    enum PhysicsCategory {
        static let player: UInt32 = 1 << 0
        static let ground: UInt32 = 1 << 1
        static let obstacle: UInt32 = 1 << 2
        static let projectile: UInt32 = 1 << 3
        static let particle: UInt32 = 1 << 4
    }
    
    // MARK: - Layout
    enum Layout {
        static let groundHeight: CGFloat = 60
        static let groundBaseY: CGFloat = 30
    }
    
    // MARK: - Asset names
    enum Assets {
        static let playerFrame1 = "Tooth1"
        static let playerFrame2 = "Tooth2"
        static let playerFrame3 = "Tooth3"
        static let playerFrame4 = "Tooth4"
        static let playerFrame5 = "Tooth5"
        
        static let bossFrame1 = "FairyFrame1"
        static let bossFrame2 = "FairyFrame2"
        
        static let phase1ObstacleFrame1 = "Carie1"
        static let phase1ObstacleFrame2 = "Carie2"
        
        static let phase2ObstacleFrame1 = "Coke1"
        static let phase2ObstacleFrame2 = "Coke2"
        
        static let phase3ObstacleFrame1 = "Pigeon1"
        static let phase3ObstacleFrame2 = "Pigeon2"
        
        static let phase4ObstacleFrame1 = "Roach1"
        static let phase4ObstacleFrame2 = "Roach2"

        static let fairyAttack = "FairyAttack"

        static let flyingObstacleFrame1 = "fly1"
        static let flyingObstacleFrame2 = "fly2"
    }
}
