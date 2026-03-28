//
//  FuelBarSystem.swift
//  UnToothAble
//
//  ECS: Updates fuel bar visuals based on JetPackComponent state.
//

import SpriteKit
import UIKit

final class FuelBarSystem {

    private weak var playerNode: SKSpriteNode?
    private weak var worldNode: SKNode?
    var fuelBar: SKShapeNode!
    var fuelBarBorder: SKShapeNode!
    var fuelBarIcon: SKLabelNode!

    init(playerNode: SKSpriteNode, worldNode: SKNode) {
        self.playerNode = playerNode
        self.worldNode = worldNode
    }

    func setupFuelBar() {
        guard let playerNode = playerNode else { return }

        fuelBar?.removeFromParent()
        fuelBarBorder?.removeFromParent()
        fuelBarIcon?.removeFromParent()

        let barWidth: CGFloat = 14
        let barHeight: CGFloat = 50

        let borderRect = CGRect(x: -barWidth / 2, y: 0, width: barWidth, height: barHeight)
        fuelBarBorder = SKShapeNode(rect: borderRect, cornerRadius: 7)
        fuelBarBorder.fillColor = UIColor(white: 0.9, alpha: 1.0)
        fuelBarBorder.strokeColor = UIColor(red: 0.22, green: 0.54, blue: 0.87, alpha: 1)
        fuelBarBorder.lineWidth = 2
        fuelBarBorder.position = CGPoint(x: -45, y: -20)
        playerNode.addChild(fuelBarBorder)

        let fillRect = CGRect(x: -barWidth / 2 + 3, y: 3, width: barWidth - 6, height: barHeight - 6)
        fuelBar = SKShapeNode(rect: fillRect, cornerRadius: 4)
        fuelBar.fillColor = UIColor(red: 0.22, green: 0.54, blue: 0.87, alpha: 1)
        fuelBar.strokeColor = .clear
        fuelBar.position = CGPoint(x: -45, y: -20)
        playerNode.addChild(fuelBar)

        fuelBarIcon = SKLabelNode(text: "⚡")
        fuelBarIcon.fontSize = 10
        fuelBarIcon.verticalAlignmentMode = .center
        fuelBarIcon.horizontalAlignmentMode = .center
        fuelBarIcon.position = CGPoint(x: -46, y: 5)
        playerNode.addChild(fuelBarIcon)

        fuelBarBorder.zPosition = 0
        fuelBar.zPosition = 1
        fuelBarIcon.zPosition = 2
    }

    func update(world: World, playerEntity: Entity?) {
        guard let entity = playerEntity,
              let jetPack = world.component(JetPackComponent.self, for: entity),
              let playerNode = playerNode else { return }

        let fuelRatio = max(jetPack.currentFuel / jetPack.maxFuel, 0.0)
        let barHeight: CGFloat = 44
        let fillHeight = barHeight * fuelRatio
        let barWidth: CGFloat = 8

        fuelBar.removeFromParent()
        let fillRect = CGRect(x: -barWidth / 2, y: 3, width: barWidth, height: max(fillHeight, 0))
        fuelBar = SKShapeNode(rect: fillRect, cornerRadius: 4)
        fuelBar.strokeColor = .clear
        fuelBar.position = CGPoint(x: -45, y: -20)
        playerNode.addChild(fuelBar)

        switch fuelRatio {
        case 0.5...:
            fuelBar.fillColor = UIColor(red: 0.22, green: 0.54, blue: 0.87, alpha: 1)
            fuelBarBorder.strokeColor = UIColor(red: 0.22, green: 0.54, blue: 0.87, alpha: 1)
            fuelBarIcon.fontColor = .white
        case 0.2..<0.5:
            fuelBar.fillColor = UIColor(red: 0.94, green: 0.62, blue: 0.15, alpha: 1)
            fuelBarBorder.strokeColor = UIColor(red: 0.94, green: 0.62, blue: 0.15, alpha: 1)
            fuelBarIcon.fontColor = .white
        default:
            fuelBar.fillColor = UIColor(red: 0.89, green: 0.29, blue: 0.29, alpha: 1)
            fuelBarBorder.strokeColor = UIColor(red: 0.89, green: 0.29, blue: 0.29, alpha: 1)
            fuelBarIcon.fontColor = UIColor(red: 0.89, green: 0.29, blue: 0.29, alpha: 1)
        }

        if jetPack.isThrusting && jetPack.currentFuel > 0 {
            spawnLiquidParticle(from: playerNode)
        }
    }

    private func spawnLiquidParticle(from playerNode: SKSpriteNode) {
        guard let worldNode = worldNode, let scene = playerNode.scene else { return }

        let dropRadius = CGFloat.random(in: 3...6)
        let drop = SKShapeNode(circleOfRadius: dropRadius)
        drop.fillColor = UIColor(red: 1.0, green: 0.96, blue: 0.85, alpha: 1.0)
        drop.strokeColor = .clear

        let jetpackOffset = CGPoint(x: -28, y: 0)
        let spawnPosition = scene.convert(jetpackOffset, from: playerNode)
        drop.position = spawnPosition

        drop.physicsBody = SKPhysicsBody(circleOfRadius: dropRadius)
        drop.physicsBody?.isDynamic = true
        drop.physicsBody?.categoryBitMask = GameConstants.PhysicsCategory.particle
        drop.physicsBody?.collisionBitMask = 0
        drop.physicsBody?.contactTestBitMask = 0

        worldNode.addChild(drop)

        let shrink = SKAction.scale(to: 0.1, duration: 0.6)
        let fade = SKAction.fadeOut(withDuration: 0.6)
        let group = SKAction.group([shrink, fade])
        let remove = SKAction.removeFromParent()

        drop.run(SKAction.sequence([group, remove]))
    }
}
