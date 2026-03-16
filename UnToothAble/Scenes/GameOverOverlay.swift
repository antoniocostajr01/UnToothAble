//
//  GameOverOverlay.swift
//  UnToothAble
//
//  Responsabilidade: mostrar e esconder o label "Game Over - toque para reiniciar".
//

import SpriteKit

final class GameOverOverlay {

    private var label: SKLabelNode?

    func show(in scene: SKScene) {
        if label == nil {
            let node = SKLabelNode(text: "Game Over - toque para reiniciar")
            node.name = "gameOverLabel"
            node.fontName = "Avenir-Heavy"
            node.fontSize = 24
            node.fontColor = .black
            label = node
        }
        guard let label = label, label.parent == nil else { return }
        label.position = CGPoint(x: scene.size.width / 2, y: scene.size.height - 120)
        scene.addChild(label)
    }

    func hide(from scene: SKScene) {
        label?.removeFromParent()
    }
}
