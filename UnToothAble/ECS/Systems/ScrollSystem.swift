//
//  ScrollSystem.swift
//  UnToothAble
//
//  ECS: Move todas as entidades com ObstacleComponent para a esquerda (scroll do cenário). Chamado no update da GameScene.
//

import Foundation
import CoreGraphics

/// Sistema que atualiza a posição X das entidades-obstáculo para simular o scroll do cenário.
final class ScrollSystem {

    private let scenarioSpeed: CGFloat

    init(scenarioSpeed: CGFloat) {
        self.scenarioSpeed = scenarioSpeed
    }

    /// Avança o estado: move obstáculos para a esquerda.
    func update(world: World, deltaTime: TimeInterval) {
        let dx = scenarioSpeed * CGFloat(deltaTime)
        for entity in world.entities(with: [ObstacleComponent.self, PositionComponent.self]) {
            guard var pos = world.component(PositionComponent.self, for: entity) else { continue }
            pos.x -= dx
            world.addComponent(pos, to: entity)
        }
    }
}
