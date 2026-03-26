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

    static func create(in world: World) -> Entity {
        let entity = world.createEntity()
        // Intencionalmente sem PositionComponent: o boss é movido por SKActions
        // e não queremos que syncPositionToNodes() sobrescreva sua posição.
        world.addComponent(BossComponent(), to: entity)
        return entity
    }
}
