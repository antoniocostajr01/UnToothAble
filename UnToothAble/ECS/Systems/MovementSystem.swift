//
//  MovementSystem.swift
//  UnToothAble
//
//  ECS: Updates position from velocity each frame. Operates on entities that have both Position and Velocity components.
//

import Foundation
import CoreGraphics

/// System that applies velocity to position over time. Call from your game loop (e.g. GameScene update).
final class MovementSystem {

    func update(world: World, deltaTime: TimeInterval) {
        let dt = CGFloat(deltaTime)
        for entity in world.entities(with: [PositionComponent.self, VelocityComponent.self]) {
            guard var pos = world.component(PositionComponent.self, for: entity),
                  let vel = world.component(VelocityComponent.self, for: entity) else { continue }
            pos.x += vel.dx * dt
            pos.y += vel.dy * dt
            world.addComponent(pos, to: entity)
        }
    }
}
