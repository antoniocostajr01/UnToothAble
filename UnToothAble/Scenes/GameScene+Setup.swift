import SpriteKit

extension GameScene {

    func setupGround() {
        let groundHeight = GameConstants.Layout.groundHeight
        let groundY = GameConstants.Layout.groundBaseY

        for i in 0..<2 {
            let ground = SKSpriteNode(color: .clear, size: CGSize(width: size.width, height: groundHeight))
            ground.position = CGPoint(x: size.width / 2 + CGFloat(i) * size.width, y: groundY)
            worldNode.addChild(ground)
            groundPieces.append(ground)
        }
    }

    func setupPhysicsGround() {
        let groundHeight = GameConstants.Layout.groundHeight
        let groundY = GameConstants.Layout.groundBaseY

        let physicsGround = SKNode()
        physicsGround.name = "physicsGround" // ← adicione isso
        physicsGround.position = CGPoint(x: size.width / 2, y: groundY)

        let body = SKPhysicsBody(
            rectangleOf: CGSize(width: size.width * 2, height: groundHeight)
        )
        
        body.isDynamic = false
        body.friction = 0.0          // evita que o player "grude" lateralmente
        body.restitution = 0.0 
        
        body.categoryBitMask = GameConstants.PhysicsCategory.ground
        body.contactTestBitMask = GameConstants.PhysicsCategory.player
        body.collisionBitMask = 0
        
        physicsGround.physicsBody = body

        addChild(physicsGround)
    }
    
    func setupPlayer() {
        fixedPlayerX = size.width * 0.25

        player.size = CGSize(width: 70, height: 70)
        player.position = CGPoint(x: fixedPlayerX, y: 180)
        
        let playerTextures: [SKTexture] = [
            SKTexture(imageNamed: GameConstants.Assets.playerFrame1),
            SKTexture(imageNamed: GameConstants.Assets.playerFrame2),
            SKTexture(imageNamed: GameConstants.Assets.playerFrame3),
            SKTexture(imageNamed: GameConstants.Assets.playerFrame4),
            SKTexture(imageNamed: GameConstants.Assets.playerFrame5)
        ]
        
        let runAnimation = SKAction.animate(with: playerTextures, timePerFrame: 0.1)
        player.run(.repeatForever(runAnimation), withKey: "playerRun")

        player.physicsBody = SKPhysicsBody(circleOfRadius: 25)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.restitution = 0
        player.physicsBody?.friction = 1
        player.physicsBody?.linearDamping = 0
        player.physicsBody?.categoryBitMask = GameConstants.PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = GameConstants.PhysicsCategory.obstacle | GameConstants.PhysicsCategory.ground | GameConstants.PhysicsCategory.projectile
        player.physicsBody?.collisionBitMask = GameConstants.PhysicsCategory.ground | GameConstants.PhysicsCategory.obstacle | GameConstants.PhysicsCategory.projectile

        addChild(player)

        fuelBar?.removeFromParent()
        fuelBarBorder?.removeFromParent()
        fuelBarIcon?.removeFromParent()

        let barWidth: CGFloat = 14
        let barHeight: CGFloat = 50

        let borderRect = CGRect(x: -barWidth / 2, y: 0, width: barWidth, height: barHeight)
        fuelBarBorder = SKShapeNode(rect: borderRect, cornerRadius: 7)
        fuelBarBorder.fillColor = UIColor(white: 0.9, alpha: 1.0)
        fuelBarBorder.strokeColor = UIColor(red: 0.22, green: 0.54, blue: 0.87, alpha: 1)
        fuelBarBorder.lineWidth = 2
        fuelBarBorder.position = CGPoint(x: -45, y: -20)
        player.addChild(fuelBarBorder)

        let fillRect = CGRect(x: -barWidth / 2 + 3, y: 3, width: barWidth - 6, height: barHeight - 6)
        fuelBar = SKShapeNode(rect: fillRect, cornerRadius: 4)
        fuelBar.fillColor = UIColor(red: 0.22, green: 0.54, blue: 0.87, alpha: 1)
        fuelBar.strokeColor = .clear
        fuelBar.position = CGPoint(x: -45, y: -20)
        player.addChild(fuelBar)

        fuelBarIcon = SKLabelNode(text: "⚡")
        fuelBarIcon.fontSize = 10
        fuelBarIcon.verticalAlignmentMode = .center
        fuelBarIcon.horizontalAlignmentMode = .center
        fuelBarIcon.position = CGPoint(x: -46, y: 5)
        player.addChild(fuelBarIcon)

        fuelBarBorder.zPosition = 0
        fuelBar.zPosition = 1
        fuelBarIcon.zPosition = 2

        let entity = PlayerFactory.create(in: ecsWorld)
        ecsWorld.addComponent(PositionComponent(x: player.position.x, y: player.position.y), to: entity)
        ecsWorld.addComponent(SpriteComponent(node: player), to: entity)
        playerEntity = entity
    }

    func setupBoss() {
        if isGameOver { return }

        let startPos = CGPoint(x: size.width + 250, y: size.height * 0.70)

        let boss = SKSpriteNode(imageNamed: GameConstants.Assets.bossFrame1)
        boss.name = "boss"
        boss.size = CGSize(width: 200, height: 200)
        boss.position = startPos

        let texture1 = SKTexture(imageNamed: GameConstants.Assets.bossFrame1)
        let texture2 = SKTexture(imageNamed: GameConstants.Assets.bossFrame2)
        let flapAnimation = SKAction.animate(with: [texture1, texture2], timePerFrame: 0.2)
        boss.run(.repeatForever(flapAnimation), withKey: "bossFlap")

        worldNode.addChild(boss)

        let entity = BossFactory.create(in: ecsWorld, at: startPos)
        ecsWorld.addComponent(SpriteComponent(node: boss), to: entity)

        startBossBehavior(for: boss)
    }

    private func startBossBehavior(for node: SKNode) {
        if isGameOver { return }

        let limitBottom = GameConstants.Layout.groundBaseY + GameConstants.Layout.groundHeight + 5.8

        let limitTop = size.height - 100.0

        let moveDown = SKAction.moveTo(y: limitBottom, duration: 2.0)
        moveDown.timingMode = .easeInEaseOut

        let moveUp = SKAction.moveTo(y: limitTop, duration: 2.0)
        moveUp.timingMode = .easeInEaseOut

        node.run(.repeatForever(.sequence([moveDown, moveUp])), withKey: "bossVerticalMovement")
        
        let moveIn = SKAction.moveTo(x: size.width - 200, duration: 1.0)
        moveIn.timingMode = .easeOut
        
        let waitToShoot = SKAction.wait(forDuration: 1.5, withRange: 1.0)
        let shoot = SKAction.run { [weak self, weak node] in
            guard let self = self, let node = node else { return }
            self.spawnBossProjectile(from: node.position)
        }

        let attackPhase = SKAction.repeat(.sequence([waitToShoot, shoot]), count: Int.random(in: 3...6))
        
        let moveOut = SKAction.moveTo(x: size.width + 200, duration: 1.0)
        moveOut.timingMode = .easeIn
        
        let cleanup = SKAction.run { [weak self, weak node] in
            guard let self = self, let node = node else { return }
            self.removeBossEntity(for: node)
            node.removeFromParent()
        }

        let fullCycle = SKAction.sequence([moveIn, attackPhase, moveOut, cleanup])
        node.run(fullCycle, withKey: "bossMainCycle")
    }
    
    private func spawnBossProjectile(from position: CGPoint) {
        if isGameOver { return }
        
        let projectile = SKShapeNode(circleOfRadius: 12)
        projectile.fillColor = .white
        projectile.strokeColor = .clear
        projectile.position = position

        projectile.physicsBody = SKPhysicsBody(circleOfRadius: 8)
        projectile.physicsBody?.isDynamic = false
        projectile.physicsBody?.categoryBitMask = GameConstants.PhysicsCategory.projectile
        projectile.physicsBody?.contactTestBitMask = GameConstants.PhysicsCategory.player
        projectile.physicsBody?.collisionBitMask = GameConstants.PhysicsCategory.player
        
        worldNode.addChild(projectile)
        
        let moveLeft = SKAction.moveBy(x: -size.width - 100, y: 0, duration: 3.0)
        let remove = SKAction.removeFromParent()
        projectile.run(.sequence([moveLeft, remove]))
    }

    func removeBossEntity(for node: SKNode) {
        let bosses = ecsWorld.entities(with: [SpriteComponent.self])
        
        for entity in bosses {
            guard let sprite = ecsWorld.component(SpriteComponent.self, for: entity) else { continue }
            if sprite.node === node {
                ecsWorld.removeEntity(entity)
                break
            }
        }
    }
    
    private func currentObstacleTextures() -> [SKTexture] {
        switch currentPhase {
        case 1:
            return [
                SKTexture(imageNamed: GameConstants.Assets.phase1ObstacleFrame1),
                SKTexture(imageNamed: GameConstants.Assets.phase1ObstacleFrame2)
            ]
        case 2:
            return [
                SKTexture(imageNamed: GameConstants.Assets.phase2ObstacleFrame1),
                SKTexture(imageNamed: GameConstants.Assets.phase2ObstacleFrame2)
            ]
        case 3:
            return [
                SKTexture(imageNamed: GameConstants.Assets.phase3ObstacleFrame1),
                SKTexture(imageNamed: GameConstants.Assets.phase3ObstacleFrame2)
            ]
        default:
            return [
                SKTexture(imageNamed: GameConstants.Assets.phase4ObstacleFrame1),
                SKTexture(imageNamed: GameConstants.Assets.phase4ObstacleFrame2)
            ]
        }
    }

    func spawnObstacle() {
        if isGameOver { return }

        let obstacleTextures = currentObstacleTextures()
        let obstacle = SKSpriteNode(texture: obstacleTextures[0])

        obstacle.size = CGSize(width: 100, height: 100)

        let spawnPosition = CGPoint(x: size.width + 60, y: 90)
        obstacle.position = spawnPosition

        let obstacleAnimation = SKAction.animate(with: obstacleTextures, timePerFrame: 0.15)
        obstacle.run(.repeatForever(obstacleAnimation), withKey: "obstacleAnimation")

        obstacle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 60))
        obstacle.physicsBody?.isDynamic = false
        obstacle.physicsBody?.categoryBitMask = GameConstants.PhysicsCategory.obstacle
        obstacle.physicsBody?.contactTestBitMask = GameConstants.PhysicsCategory.player
        obstacle.physicsBody?.collisionBitMask = GameConstants.PhysicsCategory.player

        worldNode.addChild(obstacle)

        let entity = ObstacleFactory.create(in: ecsWorld, at: spawnPosition)
        ecsWorld.addComponent(SpriteComponent(node: obstacle), to: entity)
    }
    
    // MARK: Lógica para adicionar obstáculos voadores no futuro
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
