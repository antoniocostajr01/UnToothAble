//
//  GroundSystem.swift
//  UnToothAble
//
//  ECS: Moves and recycles ground pieces.
//

import SpriteKit

final class GroundSystem {

    private var groundPieces: [SKSpriteNode] = []

    var pieces: [SKSpriteNode] { groundPieces }

    func setup(in size: CGSize, worldNode: SKNode) {
        groundPieces.removeAll()

        let groundHeight = GameConstants.Layout.groundHeight
        let groundY = GameConstants.Layout.groundBaseY

        for i in 0..<2 {
            let ground = SKSpriteNode(color: .clear, size: CGSize(width: size.width, height: groundHeight))
            ground.position = CGPoint(x: size.width / 2 + CGFloat(i) * size.width, y: groundY)
            worldNode.addChild(ground)
            groundPieces.append(ground)
        }
    }

    func update(deltaTime: TimeInterval, currentSpeed: CGFloat) {
        let moveX = currentSpeed * CGFloat(deltaTime)
        for ground in groundPieces {
            ground.position.x -= moveX
        }

        for ground in groundPieces {
            if ground.position.x < -ground.size.width / 2 {
                let rightMostX = groundPieces.map(\.position.x).max() ?? 0
                ground.position.x = rightMostX + ground.size.width
            }
        }
    }

    func reset(in size: CGSize, worldNode: SKNode) {
        for piece in groundPieces {
            piece.removeFromParent()
        }
        setup(in: size, worldNode: worldNode)
    }
}
