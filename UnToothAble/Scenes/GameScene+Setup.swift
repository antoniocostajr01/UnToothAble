//
//  GameScene+Setup.swift
//  UnToothAble
//
//  Responsabilidade: configuração inicial da cena (chão, física, jogador, spawn de obstáculos).
//

import SpriteKit

extension GameScene {

    func setupGround() {
        let groundHeight = GameConstants.Layout.groundHeight
        let groundY = GameConstants.Layout.groundBaseY

        for i in 0..<2 {
            let ground = SKSpriteNode(color: .systemGreen, size: CGSize(width: size.width, height: groundHeight))
            ground.position = CGPoint(x: size.width / 2 + CGFloat(i) * size.width, y: groundY)
            worldNode.addChild(ground)
            groundPieces.append(ground)
        }
    }

    func setupPhysicsGround() {
        let groundHeight = GameConstants.Layout.groundHeight
        let groundY = GameConstants.Layout.groundBaseY

        let physicsGround = SKNode()
        physicsGround.position = CGPoint(x: size.width / 2, y: groundY)
        physicsGround.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 2, height: groundHeight))
        physicsGround.physicsBody?.isDynamic = false
        physicsGround.physicsBody?.categoryBitMask = GameConstants.PhysicsCategory.ground
        physicsGround.physicsBody?.contactTestBitMask = GameConstants.PhysicsCategory.player
        physicsGround.physicsBody?.collisionBitMask = GameConstants.PhysicsCategory.player

        addChild(physicsGround)
    }

    func setupPlayer() {
        fixedPlayerX = size.width * 0.25

        player.size = CGSize(width: 70, height: 70)
        player.position = CGPoint(x: fixedPlayerX, y: 180)

        player.physicsBody = SKPhysicsBody(circleOfRadius: 25)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.restitution = 0
        player.physicsBody?.friction = 1
        player.physicsBody?.linearDamping = 0
        player.physicsBody?.categoryBitMask = GameConstants.PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = GameConstants.PhysicsCategory.obstacle | GameConstants.PhysicsCategory.ground
        player.physicsBody?.collisionBitMask = GameConstants.PhysicsCategory.ground | GameConstants.PhysicsCategory.obstacle

        addChild(player)

        let entity = PlayerFactory.create(in: ecsWorld)
        ecsWorld.addComponent(PositionComponent(x: player.position.x, y: player.position.y), to: entity)
        ecsWorld.addComponent(SpriteComponent(node: player), to: entity)
        playerEntity = entity
    }
    
    func startSpawningObstacles() {
        let spawn = SKAction.run { [weak self] in self?.spawnObstacle() }
        let wait = SKAction.wait(forDuration: 1.8)
        run(.repeatForever(.sequence([spawn, wait])), withKey: "spawnObstacles")
    }

    func spawnObstacle() {
        if isGameOver { return }

        let obstacle = SKSpriteNode(color: .systemRed, size: CGSize(width: 30, height: 55))
        let spawnPosition = CGPoint(x: size.width + 60, y: 150)
        obstacle.position = spawnPosition

        obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
        obstacle.physicsBody?.isDynamic = false
        obstacle.physicsBody?.categoryBitMask = GameConstants.PhysicsCategory.obstacle
        obstacle.physicsBody?.contactTestBitMask = GameConstants.PhysicsCategory.player
        obstacle.physicsBody?.collisionBitMask = GameConstants.PhysicsCategory.player

        worldNode.addChild(obstacle)

        let entity = ObstacleFactory.create(in: ecsWorld, at: spawnPosition)
        ecsWorld.addComponent(SpriteComponent(node: obstacle), to: entity)
    }
}
