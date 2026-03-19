import SpriteKit

class AnimationSystem {
    func update(world: World, deltaTime: TimeInterval) {
        let entities = world.entities(with: [SpriteComponent.self, AnimationComponent.self])

        for entity in entities {
            guard let sprite = world.component(SpriteComponent.self, for: entity),
                  var anim = world.component(AnimationComponent.self, for: entity),
                  let body = sprite.node.physicsBody else { continue }

            let node = sprite.node

            let isTouchingGround = body.allContactedBodies().contains { contactedBody in
                return contactedBody.categoryBitMask == GameConstants.PhysicsCategory.ground
            }

            let isAirborne = !isTouchingGround

            if isAirborne && !anim.isPaused {
                node.speed = 0
                anim.isPaused = true
                world.addComponent(anim, to: entity)

            } else if !isAirborne && anim.isPaused {
                node.speed = 1
                anim.isPaused = false
                world.addComponent(anim, to: entity)
            }
        }
    }
}
