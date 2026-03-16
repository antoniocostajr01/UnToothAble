//
//  ObstacleFactory.swift
//  UnToothAble
//
//  ECS: Creates obstacle entities (e.g. for spawning in GameScene). Attach PositionComponent and any obstacle-specific data.
//

import Foundation
import CoreGraphics

/// Factory that builds obstacle entities with PositionComponent and ObstacleComponent. A cena adiciona SpriteComponent ao spawar o nó.
enum ObstacleFactory {

    static func create(in world: World, at position: CGPoint) -> Entity {
        let entity = world.createEntity()
        world.addComponent(PositionComponent(x: position.x, y: position.y), to: entity)
        world.addComponent(ObstacleComponent(), to: entity)
        return entity
    }
}
