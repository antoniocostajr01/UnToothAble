//
//  CollisionHandler.swift
//  UnToothAble
//
//  Responsabilidade: interpretar contactos físicos e devolver o tipo de colisão (chão vs obstáculo).
//

import SpriteKit

enum CollisionResult {
    case groundTouched
    case groundLeft
    case obstacleHit
    case none
}

enum CollisionHandler {

    static func handle(_ contact: SKPhysicsContact) -> CollisionResult {
        let categories = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if categories == GameConstants.PhysicsCategory.player | GameConstants.PhysicsCategory.ground {
            return .groundTouched
        }
        if categories == GameConstants.PhysicsCategory.player | GameConstants.PhysicsCategory.obstacle {
            return .obstacleHit
        }
        if categories == GameConstants.PhysicsCategory.player | GameConstants.PhysicsCategory.projectile {
            return .obstacleHit
        }
        return .none
    }

    static func handleEnd(_ contact: SKPhysicsContact) -> CollisionResult {
        let categories = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if categories == GameConstants.PhysicsCategory.player | GameConstants.PhysicsCategory.ground {
            return .groundLeft
        }
        return .none
    }
}
