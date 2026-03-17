//
//  JetPackSystem.swift
//  UnToothAble
//
//  ECS: Applies jetpack thrust forces to the player sprite physics body and consumes fuel.
//

import Foundation
import CoreGraphics
import SpriteKit

/// System that applies jetpack physics (hover force) when thrusting and fuel is available.
final class JetPackSystem {

    func update(world: World, deltaTime: TimeInterval) {
        for entity in world.entities(with: [JetPackComponent.self, SpriteComponent.self]) {
            guard var jetPack = world.component(JetPackComponent.self, for: entity),
                  let sprite = world.component(SpriteComponent.self, for: entity) else { continue }

            if jetPack.isThrusting && jetPack.currentFuel > 0 {
                sprite.node.physicsBody?.applyForce(CGVector(dx: 0.0, dy: jetPack.hoverForce))

                jetPack.currentFuel -= jetPack.fuelConsumptionRate

                if jetPack.currentFuel <= 0 {
                    jetPack.currentFuel = 0
                    jetPack.isThrusting = false
                }

                world.addComponent(jetPack, to: entity)
            }
        }
    }
}
