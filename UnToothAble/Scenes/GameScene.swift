//
//  GameScene.swift
//  UnToothAble
//
//  Orquestra a cena: ECS, loop de jogo, sincronização SpriteKit ↔ ECS. Setup e HUD/colisões/game over estão em tipos dedicados.
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - ECS
    var ecsWorld = World()
    private var scrollSystem: ScrollSystem!
    var playerEntity: Entity?
    
    var gameManager: GameManager?
    
    private var currentScenarioSpeed: CGFloat = GameConstants.Physics.scenarioSpeed
    
    // Nós da cena
    let worldNode = SKNode()
    let player = SKSpriteNode(imageNamed: GameConstants.Assets.playerImage)
    private let background = ScrollingBackground()
    
    // Estado
    var groundPieces: [SKSpriteNode] = []
    var isGameOver = false
    private var canJump = true
    var lastUpdateTime: TimeInterval = 0
    
    private weak var lastHitObstacleNode: SKNode?
    var fixedPlayerX: CGFloat = 0
    private var hasPerformedInitialSetup = false

    // Pontuação
    private var score: Int = 0
    private var scoreAccumulator: TimeInterval = 0
    
    // Spawn por tempo fixo
    private var obstacleSpawnAccumulator: TimeInterval = 0
    private let obstacleSpawnInterval: TimeInterval = 1.8
    
    private var bossSpawnAccumulator: TimeInterval = 0
    private let bossSpawnInterval: TimeInterval = 10.0
    
    // Responsabilidades extraídas
    private let gameHUD = GameHUD()
    private let gameOverOverlay = GameOverOverlay()
           
    var onGameOver: ((Int) -> Void)?

    override func didMove(to view: SKView) {
        size = view.bounds.size
        backgroundColor = .clear

        physicsWorld.gravity = CGVector(dx: 0, dy: GameConstants.Physics.gravityY)
        physicsWorld.contactDelegate = self

        if hasPerformedInitialSetup {
            return
        }

        hasPerformedInitialSetup = true

        scrollSystem = ScrollSystem(scenarioSpeed: GameConstants.Physics.scenarioSpeed)

        addChild(background)
        background.setup(in: size)

        background.onLevelUp = { [weak self] in
            guard let self = self else { return }
            self.currentScenarioSpeed += GameConstants.Physics.speedIncrement
            print("🚀 LEVEL UP! Nova velocidade: \(self.currentScenarioSpeed)")
        }

        addChild(worldNode)

        setupGround()
        setupPhysicsGround()
        setupPlayer()
        gameHUD.addTo(scene: self)
        gameHUD.update(score: score, bestScore: LocalScoreStore.shared.bestScore)
        
        obstacleSpawnAccumulator = 0
        bossSpawnAccumulator = 0
    }
    
    private func prepareForReuse() {
        removeAllActions()
        removeAllChildren()
        worldNode.removeAllChildren()
        groundPieces.removeAll()
        ecsWorld = World()
        scrollSystem = ScrollSystem(scenarioSpeed: GameConstants.Physics.scenarioSpeed)
        playerEntity = nil
        isGameOver = false
        canJump = true
        score = 0
        scoreAccumulator = 0
        obstacleSpawnAccumulator = 0
        bossSpawnAccumulator = 0
    }
    
    private func jump() {
        if !canJump || isGameOver { return }
        canJump = false
        player.physicsBody?.velocity = .zero
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 120)) 
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGameOver else { return }
        jump()
    }
    
    // MARK: - Game loop
    override func update(_ currentTime: TimeInterval) {
        var deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        if deltaTime > 1 {
            deltaTime = 1.0 / 60.0
        }
        
        guard !isGameOver else { return }
        
        updateObstacleSpawn(deltaTime: deltaTime)
        updateBossSpawn(deltaTime: deltaTime)
        
        scoreAccumulator += deltaTime
        if scoreAccumulator >= 1 {
            score += 1
            scoreAccumulator = 0
            gameHUD.update(score: score, bestScore: LocalScoreStore.shared.bestScore)
        }
        
        let currentSpeed = self.currentScenarioSpeed
        
        syncPlayerPositionFromNode()
        scrollSystem.update(world: ecsWorld, deltaTime: deltaTime, scenarioSpeed: currentSpeed)
        syncPositionToNodes()
        moveGroundOnly(deltaTime: deltaTime, currentSpeed: currentSpeed)
        recycleGround()
        removeOffscreenObstacles()
        background.update(deltaTime: deltaTime, scenarioSpeed: currentSpeed)
    }
    
    // MARK: - Spawn timers
    private func updateObstacleSpawn(deltaTime: TimeInterval) {
        obstacleSpawnAccumulator += deltaTime
        
        while obstacleSpawnAccumulator >= obstacleSpawnInterval {
            obstacleSpawnAccumulator -= obstacleSpawnInterval
            spawnObstacle()
        }
    }
    
    private func updateBossSpawn(deltaTime: TimeInterval) {
        bossSpawnAccumulator += deltaTime
        
        while bossSpawnAccumulator >= bossSpawnInterval {
            bossSpawnAccumulator -= bossSpawnInterval
            setupBoss()
        }
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
    
    private func moveGroundOnly(deltaTime: TimeInterval, currentSpeed: CGFloat) {
        let moveX = currentSpeed * CGFloat(deltaTime)
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

        obstacleSpawnAccumulator = 0
        bossSpawnAccumulator = 0

        player.position.x = fixedPlayerX
        player.physicsBody?.velocity = .zero
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 80))

        canJump = false
        isGameOver = false
        gameOverOverlay.hide(from: self)
        lastUpdateTime = 0
    }
    
    // MARK: - Colisões
    func didBegin(_ contact: SKPhysicsContact) {
        switch CollisionHandler.handle(contact) {
        case .groundTouched:
            canJump = true

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

        LocalScoreStore.shared.saveIfNeeded(score: score)
        onGameOver?(score)
    }

    func restartGame() {
        isGameOver = false
        canJump = true
        score = 0
        currentScenarioSpeed = GameConstants.Physics.scenarioSpeed
        scoreAccumulator = 0
        obstacleSpawnAccumulator = 0
        bossSpawnAccumulator = 0
        
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
    }
}
