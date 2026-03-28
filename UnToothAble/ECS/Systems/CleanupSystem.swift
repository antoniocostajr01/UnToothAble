//
//  CleanupSystem.swift
//  UnToothAble
//
//  ECS: Removes offscreen obstacle entities and their sprite nodes.
//

import Foundation
import SpriteKit

final class CleanupSystem {

    func update(world: World) {
        let toRemove = world.entities(with: [ObstacleComponent.self, SpriteComponent.self, PositionComponent.self])
            .filter { entity in
                (world.component(PositionComponent.self, for: entity)?.x ?? 0) < -100
            }

        for entity in toRemove {
            world.component(SpriteComponent.self, for: entity)?.node.removeFromParent()
            world.removeEntity(entity)
        }
    }
}
