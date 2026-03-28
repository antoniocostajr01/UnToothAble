import SpriteKit

extension GameScene {

    func setupPhysicsGround() {
        let groundHeight = GameConstants.Layout.groundHeight
        let groundY = GameConstants.Layout.groundBaseY

        let physicsGround = SKNode()
        physicsGround.name = "physicsGround"
        physicsGround.position = CGPoint(x: size.width / 2, y: groundY)

        let body = SKPhysicsBody(
            rectangleOf: CGSize(width: size.width * 2, height: groundHeight)
        )
        
        body.isDynamic = false
        body.friction = 0.0
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

        fuelBarSystem = FuelBarSystem(playerNode: player, worldNode: worldNode)
        fuelBarSystem.setupFuelBar()

        groundSystem.setup(in: size, worldNode: worldNode)

        let entity = PlayerFactory.create(in: ecsWorld)
        ecsWorld.addComponent(PositionComponent(x: player.position.x, y: player.position.y), to: entity)
        ecsWorld.addComponent(SpriteComponent(node: player), to: entity)
        playerEntity = entity

        let sEntity = ecsWorld.createEntity()
        ecsWorld.addComponent(ScoreComponent(), to: sEntity)
    }
}
