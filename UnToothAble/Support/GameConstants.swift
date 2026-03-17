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
        static let gravityY: CGFloat = -30
        static let scenarioSpeed: CGFloat = 600
        static let speedIncrement: CGFloat = 100
    }

    // MARK: - Physics categories (bitmasks)
    enum PhysicsCategory {
        static let player: UInt32 = 1 << 0
        static let ground: UInt32 = 1 << 1
        static let obstacle: UInt32 = 1 << 2
    }

    // MARK: - Layout
    enum Layout {
        static let groundHeight: CGFloat = 60
        static let groundBaseY: CGFloat = 120
    }

    // MARK: - Asset names
    enum Assets {
        static let playerImage = "Tooth"
        static let backgrounds = ["Background1", "Background2", "Background3"]
    }
}
