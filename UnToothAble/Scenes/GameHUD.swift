//
//  GameHUD.swift
//  UnToothAble
//
//  Responsabilidade: criar e atualizar os labels de score e best score na cena.
//

import SpriteKit

final class GameHUD {

    private let scoreLabel = SKLabelNode(fontNamed: "Avenir-Heavy")
    private let bestScoreLabel = SKLabelNode(fontNamed: "Avenir-Heavy")

    /// Adiciona os nós do HUD à cena e posiciona-os.
    func addTo(scene: SKScene) {
        scoreLabel.fontSize = 26
        scoreLabel.fontColor = .black
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 20, y: scene.size.height - 60)

        bestScoreLabel.fontSize = 22
        bestScoreLabel.fontColor = .darkGray
        bestScoreLabel.horizontalAlignmentMode = .left
        bestScoreLabel.position = CGPoint(x: 20, y: scene.size.height - 95)

        scene.addChild(scoreLabel)
        scene.addChild(bestScoreLabel)
    }

    /// Atualiza os textos exibidos.
    func update(score: Int, bestScore: Int) {
        scoreLabel.text = "Score: \(score)"
        bestScoreLabel.text = "Best: \(bestScore)"
    }
}
