//
//  ScrollSystem.swift
//  UnToothAble
//
//  ECS: Move todas as entidades com ObstacleComponent para a esquerda (scroll do cenário).
//

import Foundation
import CoreGraphics

/// Move obstacle entities leftward each frame to simulate world scrolling.
final class ScrollSystem {

    func update(world: World, deltaTime: TimeInterval, scenarioSpeed: CGFloat) {
        let dx = scenarioSpeed * CGFloat(deltaTime)
        for entity in world.entities(with: [ObstacleComponent.self, PositionComponent.self]) {
            guard var pos = world.component(PositionComponent.self, for: entity) else { continue }
            pos.x -= dx
            world.addComponent(pos, to: entity)
        }
    }
}
