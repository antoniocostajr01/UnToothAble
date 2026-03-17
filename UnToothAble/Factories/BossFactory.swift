//
//  BossFactory.swift
//  UnToothAble
//
//  Created by Richard Fagundes Rodrigues on 16/03/26.
//

import CoreGraphics
import SpriteKit

enum BossFactory {

    static func create(in world: World, at position: CGPoint) -> Entity {
        let entity = world.createEntity()
        return entity
    }
}
