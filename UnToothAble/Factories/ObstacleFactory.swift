//
//  ObstacleFactory.swift
//  UnToothAble
//
//  ECS: Creates obstacle entities (e.g. for spawning in GameScene). Attach PositionComponent and any obstacle-specific data.
//

import Foundation
import CoreGraphics

enum ObstacleFactory {

    static func create(in world: World, at position: CGPoint) -> Entity {
        let entity = world.createEntity()
        world.addComponent(PositionComponent(x: position.x, y: position.y), to: entity)
        world.addComponent(ObstacleComponent(), to: entity)
        return entity
    }
}
