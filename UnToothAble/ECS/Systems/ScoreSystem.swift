//
//  ScoreSystem.swift
//  UnToothAble
//
//  ECS: Increments score over time and updates the HUD.
//

import Foundation

final class ScoreSystem {

    private let hud: GameHUD

    init(hud: GameHUD) {
        self.hud = hud
    }

    func update(world: World, deltaTime: TimeInterval) {
        for entity in world.entities(with: [ScoreComponent.self]) {
            guard var score = world.component(ScoreComponent.self, for: entity) else { continue }

            score.accumulator += deltaTime
            if score.accumulator >= 1 {
                score.score += 1
                score.accumulator = 0
                hud.update(score: score.score, bestScore: LocalScoreStore.shared.bestScore)
            }

            world.addComponent(score, to: entity)
        }
    }

    func currentScore(world: World) -> Int {
        for entity in world.entities(with: [ScoreComponent.self]) {
            if let score = world.component(ScoreComponent.self, for: entity) {
                return score.score
            }
        }
        return 0
    }
}
