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
        player.physicsBody?.contactTestBitMask = GameConstants.PhysicsCategory.obstacle | GameConstants.PhysicsCategory.ground | GameConstants.PhysicsCategory.projectile
        player.physicsBody?.collisionBitMask = GameConstants.PhysicsCategory.ground | GameConstants.PhysicsCategory.obstacle | GameConstants.PhysicsCategory.projectile

        addChild(player)

        fuelBar = SKShapeNode(rectOf: CGSize(width: 40, height: 6))
        fuelBar.fillColor = .systemGreen
        fuelBar.strokeColor = .clear
        fuelBar.position = CGPoint(x: 0, y: 40)
        player.addChild(fuelBar)

        let entity = PlayerFactory.create(in: ecsWorld)
        ecsWorld.addComponent(PositionComponent(x: player.position.x, y: player.position.y), to: entity)
        ecsWorld.addComponent(SpriteComponent(node: player), to: entity)
        playerEntity = entity
    }

    func startSpawningBoss() {
        let wait = SKAction.wait(forDuration: 10.0)
        let spawn = SKAction.run { [weak self] in self?.setupBoss() }

        run(.sequence([wait, spawn]), withKey: "spawnBoss")
    }

    func setupBoss() {
        if isGameOver { return }

        let startPos = CGPoint(x: size.width + 250, y: size.height * 0.75)

        let boss = SKSpriteNode(imageNamed: GameConstants.Assets.bossFrame1)
        boss.size = CGSize(width: 400, height: 400)
        boss.position = startPos

        let texture1 = SKTexture(imageNamed: GameConstants.Assets.bossFrame1)
        let texture2 = SKTexture(imageNamed: GameConstants.Assets.bossFrame2)
        let flapAnimation = SKAction.animate(with: [texture1, texture2], timePerFrame: 0.2)
                boss.run(.repeatForever(flapAnimation))

        worldNode.addChild(boss)

        let entity = BossFactory.create(in: ecsWorld, at: startPos)
        ecsWorld.addComponent(SpriteComponent(node: boss), to: entity)

        startBossBehavior(for: boss)
    }

    private func startBossBehavior(for node: SKNode) {

        if isGameOver { return }

        let minY = GameConstants.Layout.groundBaseY + (GameConstants.Layout.groundHeight / 2) + (node.frame.size.height / 2)
        let maxY = size.height - (node.frame.size.height)

        let moveDown = SKAction.moveTo(y: minY, duration: 2.0)
        moveDown.timingMode = .easeInEaseOut
        let moveUp = SKAction.moveTo(y: maxY, duration: 2.0)
        moveUp.timingMode = .easeInEaseOut
        node.run(.repeatForever(.sequence([moveDown, moveUp])))
        
        let moveIn = SKAction.moveTo(x: size.width - 200, duration: 1.0)
        let waitToShoot = SKAction.wait(forDuration: 1.5, withRange: 1.0)
        let shoot = SKAction.run { [weak self] in
            self?.spawnBossProjectile(from: node.position)
        }
        let attackPhase = SKAction.repeat(.sequence([waitToShoot, shoot]), count: Int.random(in: 3...6))
        
        let moveOut = SKAction.moveTo(x: size.width + 250, duration: 1.0)
        let cooldown = SKAction.wait(forDuration: 10.0)

        let fullCycle = SKAction.sequence([moveIn, attackPhase, moveOut, cooldown])
        node.run(.repeatForever(fullCycle))
    }
    
    private func spawnBossProjectile(from position: CGPoint) {
        if isGameOver { return }
        
        let projectile = SKShapeNode(circleOfRadius: 8)
        projectile.fillColor = .green
        projectile.strokeColor = .clear
        projectile.position = position

        projectile.physicsBody = SKPhysicsBody(circleOfRadius: 8)
        projectile.physicsBody?.isDynamic = false
        projectile.physicsBody?.categoryBitMask = GameConstants.PhysicsCategory.projectile
        projectile.physicsBody?.contactTestBitMask = GameConstants.PhysicsCategory.player
        
        worldNode.addChild(projectile)
        
        let moveLeft = SKAction.moveBy(x: -size.width - 100, y: 0, duration: 3.0)
        let remove = SKAction.removeFromParent()
        projectile.run(.sequence([moveLeft, remove]))
    }
    
    func startSpawningObstacles() {
        let spawn = SKAction.run { [weak self] in self?.spawnObstacle() }
        let wait = SKAction.wait(forDuration: 1.8)
        run(.repeatForever(.sequence([spawn, wait])), withKey: "spawnObstacles")
    }

    func spawnObstacle() {
        if isGameOver { return }

        let obstacle = SKSpriteNode(color: .systemRed, size: CGSize(width: 30, height: 55))
        let spawnPosition = CGPoint(x: size.width + 60, y: 50)
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
    
    func startSpawningAerialObstacles() {
        spawnAerialObstacleLoop()
    }
    
    private func spawnAerialObstacleLoop() {
        if isGameOver { return }
        
        let randomWait = TimeInterval.random(in: 3.0...8.0)
        let wait = SKAction.wait(forDuration: randomWait)
        let spawn = SKAction.run { [weak self] in 
            self?.spawnAerialObstacle()
            self?.spawnAerialObstacleLoop()
        }
        
        run(.sequence([wait, spawn]), withKey: "spawnAerialObstacles")
    }
    
    func spawnAerialObstacle() {
        if isGameOver { return }
        
        let aerialObstacle = SKSpriteNode(color: .systemYellow, size: CGSize(width: 20, height: 20))

        let minY = GameConstants.Layout.groundBaseY + 80
        let maxY = size.height - 50
        let randomY = CGFloat.random(in: minY...maxY)
        let randomX = size.width + CGFloat.random(in: 100...600)

        let spawnPosition = CGPoint(x: randomX, y: randomY)
        aerialObstacle.position = spawnPosition

        aerialObstacle.physicsBody = SKPhysicsBody(rectangleOf: aerialObstacle.size)
        aerialObstacle.physicsBody?.isDynamic = false
        aerialObstacle.physicsBody?.categoryBitMask = GameConstants.PhysicsCategory.obstacle
        aerialObstacle.physicsBody?.contactTestBitMask = GameConstants.PhysicsCategory.player
        aerialObstacle.physicsBody?.collisionBitMask = GameConstants.PhysicsCategory.player
        
        worldNode.addChild(aerialObstacle)
        
        let entity = ObstacleFactory.create(in: ecsWorld, at: spawnPosition)
        ecsWorld.addComponent(SpriteComponent(node: aerialObstacle), to: entity)
    }
}
