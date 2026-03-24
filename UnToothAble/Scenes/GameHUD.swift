//
//  GameHUD.swift
//  UnToothAble
//
//  Responsabilidade: criar e atualizar o HUD visual de distância e best score.
//

import SpriteKit
import UIKit

final class GameHUD {

    private let distanceBackground = SKSpriteNode(imageNamed: "scoreBar")
    private let bestBackground = SKSpriteNode(imageNamed: "bestScoreBar")

    private let distanceContainer = SKNode()
    private let bestContainer = SKNode()

    private let distanceLabel = SKLabelNode(fontNamed: "Bangers-Regular")
    private let bestLabel = SKLabelNode(fontNamed: "Bangers-Regular")

    private var distanceStrokeLabels: [SKLabelNode] = []
    private var bestStrokeLabels: [SKLabelNode] = []

    private let container = SKNode()

    func addTo(scene: SKScene) {
        container.removeAllChildren()
        container.removeFromParent()

        distanceStrokeLabels.removeAll()
        bestStrokeLabels.removeAll()

        distanceBackground.anchorPoint = CGPoint(x: 0, y: 1)
        bestBackground.anchorPoint = CGPoint(x: 0, y: 1)

        distanceBackground.size = CGSize(width: 212, height: 29)
        bestBackground.size = CGSize(width: 150, height: 28)

        distanceBackground.position = CGPoint(x: 0, y: 0)
        bestBackground.position = CGPoint(x: 0, y: -distanceBackground.size.height)

        distanceContainer.position = .zero
        bestContainer.position = .zero

        distanceContainer.addChild(distanceBackground)
        bestContainer.addChild(bestBackground)

        configureMainLabel(distanceLabel, fontSize: 20)
        configureMainLabel(bestLabel, fontSize: 20)

        distanceLabel.position = CGPoint(x: 16, y: -distanceBackground.size.height / 2)
        bestLabel.position = CGPoint(
            x: 16,
            y: -distanceBackground.size.height - bestBackground.size.height / 2
        )

        distanceStrokeLabels = makeStrokeLabels(
            basedOn: distanceLabel,
            strokeColor: UIColor(red: 0.23, green: 0.23, blue: 0.23, alpha: 1.0),
            radius: 1.2
        )

        bestStrokeLabels = makeStrokeLabels(
            basedOn: bestLabel,
            strokeColor: UIColor(red: 0.23, green: 0.23, blue: 0.23, alpha: 1.0),
            radius: 1.2
        )

        for label in distanceStrokeLabels {
            distanceContainer.addChild(label)
        }
        distanceContainer.addChild(distanceLabel)

        for label in bestStrokeLabels {
            bestContainer.addChild(label)
        }
        bestContainer.addChild(bestLabel)

        container.addChild(distanceContainer)
        container.addChild(bestContainer)

        container.position = CGPoint(x: 0, y: scene.size.height - 24)
        container.zPosition = 1000

        scene.addChild(container)
    }

    func update(score: Int, bestScore: Int) {
        let distanceText = "DISTANCE: \(score) M "
        let bestText = "BEST: \(bestScore) M "

        distanceLabel.text = distanceText
        bestLabel.text = bestText

        for label in distanceStrokeLabels {
            label.text = distanceText
        }

        for label in bestStrokeLabels {
            label.text = bestText
        }
    }

    private func configureMainLabel(_ label: SKLabelNode, fontSize: CGFloat) {
        label.fontSize = fontSize
        label.fontColor = .white
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .center
        label.zPosition = 2
    }

    private func makeStrokeLabels(
        basedOn label: SKLabelNode,
        strokeColor: UIColor,
        radius: CGFloat
    ) -> [SKLabelNode] {
        let offsets: [CGPoint] = [
            CGPoint(x: -radius, y: 0),
            CGPoint(x: radius, y: 0),
            CGPoint(x: 0, y: -radius),
            CGPoint(x: 0, y: radius),
            CGPoint(x: -radius, y: -radius),
            CGPoint(x: -radius, y: radius),
            CGPoint(x: radius, y: -radius),
            CGPoint(x: radius, y: radius)
        ]

        return offsets.map { offset in
            let strokeLabel = SKLabelNode(fontNamed: label.fontName)
            strokeLabel.fontSize = label.fontSize
            strokeLabel.fontColor = strokeColor
            strokeLabel.horizontalAlignmentMode = label.horizontalAlignmentMode
            strokeLabel.verticalAlignmentMode = label.verticalAlignmentMode
            strokeLabel.position = CGPoint(
                x: label.position.x + offset.x,
                y: label.position.y + offset.y
            )
            strokeLabel.zPosition = 1
            return strokeLabel
        }
    }
}
