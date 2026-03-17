//
//  GameScene.swift
//  UnToothAble
//
//  Orquestra a cena: ECS, loop de jogo, sincronização SpriteKit ↔ ECS. Setup e HUD/colisões/game over estão em tipos dedicados.
//
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - ECS
    var ecsWorld = World()
    private var scrollSystem: ScrollSystem!
    private var jetPackSystem = JetPackSystem()
    var playerEntity: Entity?

    // Nós da cena
    let worldNode = SKNode()
    let player = SKSpriteNode(imageNamed: GameConstants.Assets.playerImage)
    var jetpack: SKShapeNode!
    var fuelBar: SKShapeNode!
    private let background = ScrollingBackground()
    private weak var lastHitObstacleNode: SKNode?

    // Estado
    var groundPieces: [SKSpriteNode] = []
    var isGameOver = false
    var lastUpdateTime: TimeInterval = 0
    var fixedPlayerX: CGFloat = 0

    // Pontuação
    private var score: Int = 0
    private var scoreAccumulator: TimeInterval = 0

    // Responsabilidades extraídas
    private let gameHUD = GameHUD()
    private let gameOverOverlay = GameOverOverlay()
    var onGameOver: ((Int) -> Void)?

    // MARK: - Inicialização
    override func didMove(to view: SKView) {
        if background.parent != nil {
            prepareForReuse()
        }

        size = view.bounds.size
        backgroundColor = .clear

        physicsWorld.gravity = CGVector(dx: 0, dy: GameConstants.Physics.gravityY)
        physicsWorld.contactDelegate = self

        scrollSystem = ScrollSystem(scenarioSpeed: GameConstants.Physics.scenarioSpeed)

        addChild(background)
        background.setup(in: size)
        addChild(worldNode)

        setupGround()
        setupPhysicsGround()
        setupPlayer()
        gameHUD.addTo(scene: self)
        gameHUD.update(score: score, bestScore: LocalScoreStore.shared.bestScore)
        startSpawningObstacles()
//        startSpawningAerialObstacles()
        startSpawningBoss()
    }

    private func prepareForReuse() {
        removeAllActions()
        removeAllChildren()
        worldNode.removeAllChildren()
        groundPieces.removeAll()
        ecsWorld = World()
        scrollSystem = ScrollSystem(scenarioSpeed: GameConstants.Physics.scenarioSpeed)
        jetPackSystem = JetPackSystem()
        playerEntity = nil
        isGameOver = false
        score = 0
        scoreAccumulator = 0
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGameOver else { return }
        
        guard let entity = playerEntity,
              var jetPack = ecsWorld.component(JetPackComponent.self, for: entity) else { return }
              
        if jetPack.currentFuel >= jetPack.ignitionCost {
            jetPack.isThrusting = true
            jetPack.currentFuel -= jetPack.ignitionCost
            
            player.physicsBody?.velocity.dy = 0
            player.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: jetPack.jumpImpulse))
            
            ecsWorld.addComponent(jetPack, to: entity)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let entity = playerEntity,
              var jetPack = ecsWorld.component(JetPackComponent.self, for: entity) else { return }
        
        jetPack.isThrusting = false
        ecsWorld.addComponent(jetPack, to: entity)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    // MARK: - Game loop
    override func update(_ currentTime: TimeInterval) {
        var deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        if deltaTime > 1 { deltaTime = 1.0 / 60.0 }

        player.position.x = fixedPlayerX
        player.physicsBody?.velocity.dx = 0

        guard !isGameOver else { return }

        scoreAccumulator += deltaTime
        if scoreAccumulator >= 1 {
            score += 1
            scoreAccumulator = 0
            gameHUD.update(score: score, bestScore: LocalScoreStore.shared.bestScore)
        }

        syncPlayerPositionFromNode()
        scrollSystem.update(world: ecsWorld, deltaTime: deltaTime)
        jetPackSystem.update(world: ecsWorld, deltaTime: deltaTime)
        syncPositionToNodes()
        updateFuelBarVisuals()

        player.position.x = fixedPlayerX
        player.physicsBody?.velocity.dx = 0

        moveGroundOnly(deltaTime: deltaTime)
        recycleGround()
        removeOffscreenObstacles()

        background.update(deltaTime: deltaTime, scenarioSpeed: GameConstants.Physics.scenarioSpeed)
    }

    private func updateFuelBarVisuals() {
        guard let entity = playerEntity,
              let jetPack = ecsWorld.component(JetPackComponent.self, for: entity) else { return }
              
        let fuelRatio = max(jetPack.currentFuel / jetPack.maxFuel, 0.0)
        fuelBar?.xScale = fuelRatio
        fuelBar?.fillColor = fuelRatio > 0.3 ? .systemGreen : .systemRed
        
        if jetPack.isThrusting && jetPack.currentFuel > 0 {
            spawnLiquidParticle()
        }
    }

    private func spawnLiquidParticle() {
        let dropRadius = CGFloat.random(in: 3...6)
        let drop = SKShapeNode(circleOfRadius: dropRadius)
        drop.fillColor = UIColor(red: 1.0, green: 0.96, blue: 0.85, alpha: 1.0)
        drop.strokeColor = .clear
        
        guard let jetpackNode = jetpack else { return }

        // Posição ajustada baseada no sprite do jogador e jetpack
        let spawnPosition = self.convert(jetpackNode.position, from: player)
        drop.position = spawnPosition

        drop.physicsBody = SKPhysicsBody(circleOfRadius: dropRadius)
        drop.physicsBody?.isDynamic = true
        drop.physicsBody?.categoryBitMask = GameConstants.PhysicsCategory.particle
        drop.physicsBody?.collisionBitMask = GameConstants.PhysicsCategory.ground
        drop.physicsBody?.contactTestBitMask = GameConstants.PhysicsCategory.ground

        worldNode.addChild(drop)

        let shrink = SKAction.scale(to: 0.1, duration: 0.6)
        let fade = SKAction.fadeOut(withDuration: 0.6)
        let group = SKAction.group([shrink, fade])
        let remove = SKAction.removeFromParent()

        drop.run(SKAction.sequence([group, remove]))
    }

    private func syncPlayerPositionFromNode() {
        guard let entity = playerEntity,
              var pos = ecsWorld.component(PositionComponent.self, for: entity) else { return }
        pos.point = player.position
        ecsWorld.addComponent(pos, to: entity)
    }

    private func syncPositionToNodes() {
        for entity in ecsWorld.entities(with: [SpriteComponent.self, PositionComponent.self]) {
            guard let sprite = ecsWorld.component(SpriteComponent.self, for: entity),
                  let pos = ecsWorld.component(PositionComponent.self, for: entity) else { continue }
            sprite.node.position = pos.point
        }
    }

    private func moveGroundOnly(deltaTime: TimeInterval) {
        let moveX = GameConstants.Physics.scenarioSpeed * CGFloat(deltaTime)
        for ground in groundPieces {
            ground.position.x -= moveX
        }
    }

    private func recycleGround() {
        for ground in groundPieces {
            if ground.position.x < -ground.size.width / 2 {
                let rightMostX = groundPieces.map(\.position.x).max() ?? 0
                ground.position.x = rightMostX + ground.size.width
            }
        }
    }

    private func removeOffscreenObstacles() {
        let toRemove = ecsWorld.entities(with: [ObstacleComponent.self, SpriteComponent.self, PositionComponent.self])
            .filter { entity in
                (ecsWorld.component(PositionComponent.self, for: entity)?.x ?? 0) < -100
            }

        for entity in toRemove {
            ecsWorld.component(SpriteComponent.self, for: entity)?.node.removeFromParent()
            ecsWorld.removeEntity(entity)
        }
    }

    private func obstacleNode(from contact: SKPhysicsContact) -> SKNode? {
        if contact.bodyA.categoryBitMask == GameConstants.PhysicsCategory.obstacle {
            return contact.bodyA.node
        }
        if contact.bodyB.categoryBitMask == GameConstants.PhysicsCategory.obstacle {
            return contact.bodyB.node
        }
        return nil
    }

    private func removeAllObstaclesAheadOfPlayer() {
        let entitiesToRemove = ecsWorld.entities(with: [ObstacleComponent.self, SpriteComponent.self, PositionComponent.self])
            .filter { entity in
                guard let pos = ecsWorld.component(PositionComponent.self, for: entity) else { return false }
                return pos.x >= fixedPlayerX - 40
            }

        for entity in entitiesToRemove {
            ecsWorld.component(SpriteComponent.self, for: entity)?.node.removeFromParent()
            ecsWorld.removeEntity(entity)
        }
    }

    func continueRun() {
        removeAllObstaclesAheadOfPlayer()
        lastHitObstacleNode = nil

        removeAction(forKey: "spawnObstacles")
        startSpawningObstacles()

        player.position.x = fixedPlayerX
        player.physicsBody?.velocity = .zero
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 80))

        isGameOver = false
        gameOverOverlay.hide(from: self)
        lastUpdateTime = 0
    }

    // MARK: - Colisões
    func didBegin(_ contact: SKPhysicsContact) {
        
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        // Destrói partícula ao bater no chão
        if collision == (GameConstants.PhysicsCategory.particle | GameConstants.PhysicsCategory.ground) {
             let particleNode = contact.bodyA.categoryBitMask == GameConstants.PhysicsCategory.particle ? contact.bodyA.node : contact.bodyB.node
             particleNode?.removeFromParent()
             return // Don't process further
        }

        switch CollisionHandler.handle(contact) {
        case .groundTouched:
            // Refil the jetpack fuel
            if let entity = playerEntity, var jetPack = ecsWorld.component(JetPackComponent.self, for: entity) {
                jetPack.currentFuel = jetPack.maxFuel
                ecsWorld.addComponent(jetPack, to: entity)
            }

        case .obstacleHit:
            let obstacleNode = obstacleNode(from: contact)
            gameOver(hitObstacleNode: obstacleNode)

        case .none:
            break
        }
    }

    private func gameOver(hitObstacleNode: SKNode?) {
        guard !isGameOver else { return }

        isGameOver = true
        lastHitObstacleNode = hitObstacleNode

        removeAction(forKey: "spawnObstacles")
//        removeAction(forKey: "spawnAerialObstacles")
        removeAction(forKey: "spawnBoss")
        LocalScoreStore.shared.saveIfNeeded(score: score)
        onGameOver?(score)
    }

    func restartGame() {
        isGameOver = false
        score = 0
        scoreAccumulator = 0

        gameOverOverlay.hide(from: self)
        worldNode.removeAllChildren()
        groundPieces.removeAll()
        player.removeFromParent()
        removeAllActions()
        lastUpdateTime = 0

        ecsWorld = World()
        scrollSystem = ScrollSystem(scenarioSpeed: GameConstants.Physics.scenarioSpeed)

        background.reset(in: size)
        setupGround()
        setupPhysicsGround()
        setupPlayer()
        gameHUD.update(score: score, bestScore: LocalScoreStore.shared.bestScore)
        startSpawningObstacles()
//        startSpawningAerialObstacles()
        startSpawningBoss()
    }
}
