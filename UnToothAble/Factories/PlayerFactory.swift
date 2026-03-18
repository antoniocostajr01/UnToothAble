//
//  PlayerFactory.swift
//  UnToothAble
//
//  ECS: Creates the player entity and attaches its components. Use from GameScene or a setup system.
//

import Foundation
import SpriteKit
import CoreGraphics

/// Factory that builds the player entity with position, velocity, and optional sprite node reference.
enum PlayerFactory {

    static func create(in world: World) -> Entity {
        let entity = world.createEntity()
        world.addComponent(PositionComponent(x: 0, y: 0), to: entity)
        world.addComponent(VelocityComponent(dx: 0, dy: 0), to: entity)
        world.addComponent(JetPackComponent(), to: entity)
        world.addComponent(AnimationComponent(animationKey: "playerRun"), to: entity)
        return entity
    }
}
