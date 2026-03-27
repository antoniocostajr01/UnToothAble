//
//  BossFactory.swift
//  UnToothAble
//
//  ECS: Creates boss entities. Boss position is driven by SKActions,
//  NOT by PositionComponent, to avoid syncPositionToNodes() overwriting it.
//

import CoreGraphics
import SpriteKit

enum BossFactory {

    /// Creates a boss entity with only `BossComponent` and `SpriteComponent`.
    /// `PositionComponent` is intentionally omitted so `syncPositionToNodes()` does not
    /// overwrite the position driven by `SKAction`s.
    static func create(in world: World) -> Entity {
        let entity = world.createEntity()
        world.addComponent(BossComponent(), to: entity)
        return entity
    }
}
