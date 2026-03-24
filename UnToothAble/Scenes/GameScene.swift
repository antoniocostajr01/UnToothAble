//
//  GameScene.swift
//  UnToothAble
//
//  Orquestra a cena: ECS, loop de jogo, sincronização SpriteKit ↔ ECS. Setup e HUD/colisões/game over estão em tipos dedicados.
import SpriteKit
import UIKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - ECS
    var ecsWorld = World()
    private var scrollSystem: ScrollSystem!
    private var jetPackSystem = JetPackSystem()
    private var animationSystem = AnimationSystem()
    var playerEntity: Entity?
    
    var gameManager: GameManager?
    
    private var isPlayerOnGround = false
    
    private var currentScenarioSpeed: CGFloat = GameConstants.Physics.scenarioSpeed
    
    // Nós da cena
    let worldNode = SKNode()
    let player = SKSpriteNode(imageNamed: GameConstants.Assets.playerFrame1)
    var fuelBar: SKShapeNode!
    var fuelBarBorder: SKShapeNode!
    var fuelBarIcon: SKLabelNode!
    private let background = ScrollingBackground()
    
    // Estado
    var groundPieces: [SKSpriteNode] = []
    var isGameOver = false
    var lastUpdateTime: TimeInterval = 0
    var currentPhase: Int = 1
    
    
    private weak var lastHitObstacleNode: SKNode?
    var fixedPlayerX: CGFloat = 0
    private var hasPerformedInitialSetup = false

    var isGrounded: Bool = false

    // MARK: - Haptics
    private let jumpHaptic = UIImpactFeedbackGenerator(style: .light)
    private let jetpackHaptic = UIImpactFeedbackGenerator(style: .soft)
    private let hitHaptic = UINotificationFeedbackGenerator()

    private var jetpackHapticAccumulator: TimeInterval = 0
    private let jetpackHapticInterval: TimeInterval = 0.12

    private var isHapticsEnabled: Bool {
        UserDefaults.standard.object(forKey: "hapticsEnabled") as? Bool ?? true
    }

    // Pontuação
    private var score: Int = 0
    private var scoreAccumulator: TimeInterval = 0
    
    // Spawn por tempo fixo
    private var obstacleSpawnAccumulator: TimeInterval = 0
    private var currentObstacleSpawnInterval: TimeInterval = 2.0
    private let minObstacleGap: TimeInterval = 3.5
    private let maxObstacleGap: TimeInterval = 6.0

    private var bossSpawnAccumulator: TimeInterval = 0
    private let bossSpawnInterval: TimeInterval = 10.0
    
    // Responsabilidades extraídas
    private let gameHUD = GameHUD()
           
    var onGameOver: ((Int) -> Void)?

    override func didMove(to view: SKView) {
        size = view.bounds.size
        backgroundColor = .clear

        view.ignoresSiblingOrder = true
        
        physicsWorld.gravity = CGVector(dx: 0, dy: GameConstants.Physics.gravityY)
        physicsWorld.contactDelegate = self
        prepareHaptics()

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
            self.currentPhase = min(self.currentPhase + 1, 4)
            
            print("🚀 LEVEL UP! Nova velocidade: \(self.currentScenarioSpeed)")
            print("nova fase visual dos inimigos: \(self.currentPhase)")
        }
        
        addChild(worldNode)

        setupGround()
        setupPhysicsGround()
        setupPlayer()
        warmUpPhysicsAndTextures()
        gameHUD.addTo(scene: self)
        gameHUD.update(score: score, bestScore: LocalScoreStore.shared.bestScore)
        
        obstacleSpawnAccumulator = 0
        bossSpawnAccumulator = 0
    }
    
    private func warmUpPhysicsAndTextures() {
        // Força o SpriteKit a compilar o shader do physics body
        // criando e removendo um contato simulado
        let dummy = SKSpriteNode(color: .clear, size: CGSize(width: 1, height: 1))
        dummy.physicsBody = SKPhysicsBody(circleOfRadius: 1)
        dummy.physicsBody?.categoryBitMask = 0
        dummy.alpha = 0
        addChild(dummy)

        let wait = SKAction.wait(forDuration: 0.1)
        let remove = SKAction.removeFromParent()
        dummy.run(SKAction.sequence([wait, remove]))

        // Pré-aquece as texturas do player na GPU
        let preload = [
            GameConstants.Assets.playerFrame1,
            GameConstants.Assets.playerFrame2,
            GameConstants.Assets.playerFrame3,
            GameConstants.Assets.playerFrame4,
            GameConstants.Assets.playerFrame5,
        ].map { SKTexture(imageNamed: $0) }

        SKTexture.preload(preload) {}
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
        obstacleSpawnAccumulator = 0
        bossSpawnAccumulator = 0
        jetpackHapticAccumulator = 0
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGameOver else { return }
        
        guard let entity = playerEntity,
              var jetPack = ecsWorld.component(JetPackComponent.self, for: entity) else { return }

        if jetPack.currentFuel >= jetPack.ignitionCost {
            triggerJumpHaptic()

            jetPack.isThrusting = true
            jetPack.currentFuel -= jetPack.ignitionCost

            ecsWorld.addComponent(jetPack, to: entity)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let entity = playerEntity,
              var jetPack = ecsWorld.component(JetPackComponent.self, for: entity) else { return }
        
        jetPack.isThrusting = false
        ecsWorld.addComponent(jetPack, to: entity)
        jetpackHapticAccumulator = 0
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
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
        jetPackSystem.update(world: ecsWorld, deltaTime: deltaTime)
        updateJetpackHaptics(deltaTime: deltaTime)
        animationSystem.update(world: ecsWorld, deltaTime: deltaTime)
        syncPositionToNodes()
        updateFuelBarVisuals()
        moveGroundOnly(deltaTime: deltaTime, currentSpeed: currentSpeed)
        recycleGround()
        removeOffscreenObstacles()
        background.update(deltaTime: deltaTime, scenarioSpeed: currentSpeed)

        player.position.x = fixedPlayerX

        let roofLimit = size.height - (player.size.height / 2)
        if player.position.y > roofLimit {
            player.position.y = roofLimit
            if let dy = player.physicsBody?.velocity.dy, dy > 0 {
                player.physicsBody?.velocity.dy = 0
            }
        }

        player.physicsBody?.velocity.dx = 0
    }
    
    // MARK: - Spawn timers
    private func updateObstacleSpawn(deltaTime: TimeInterval) {
        obstacleSpawnAccumulator += deltaTime

        if obstacleSpawnAccumulator >= currentObstacleSpawnInterval {
            obstacleSpawnAccumulator = 0

            spawnObstacle()

            currentObstacleSpawnInterval = TimeInterval.random(in: minObstacleGap...maxObstacleGap)
        }
    }
    
    private func updateBossSpawn(deltaTime: TimeInterval) {
        bossSpawnAccumulator += deltaTime
        
        while bossSpawnAccumulator >= bossSpawnInterval {
            bossSpawnAccumulator -= bossSpawnInterval
            setupBoss()
        }
    }

    private func updateFuelBarVisuals() {
        guard let entity = playerEntity,
              let jetPack = ecsWorld.component(JetPackComponent.self, for: entity) else { return }

        let fuelRatio = max(jetPack.currentFuel / jetPack.maxFuel, 0.0)
        let barHeight: CGFloat = 44
        let fillHeight = barHeight * fuelRatio
        let barWidth: CGFloat = 8

        fuelBar.removeFromParent()
        let fillRect = CGRect(x: -barWidth / 2, y: 3, width: barWidth, height: max(fillHeight, 0))
        fuelBar = SKShapeNode(rect: fillRect, cornerRadius: 4)
        fuelBar.strokeColor = .clear
        fuelBar.position = CGPoint(x: -45, y: -20)
        player.addChild(fuelBar)

        switch fuelRatio {
        case 0.5...:
            fuelBar.fillColor = UIColor(red: 0.22, green: 0.54, blue: 0.87, alpha: 1) // azul
            fuelBarBorder.strokeColor = UIColor(red: 0.22, green: 0.54, blue: 0.87, alpha: 1)
            fuelBarIcon.fontColor = .white
        case 0.2..<0.5:
            fuelBar.fillColor = UIColor(red: 0.94, green: 0.62, blue: 0.15, alpha: 1) // laranja
            fuelBarBorder.strokeColor = UIColor(red: 0.94, green: 0.62, blue: 0.15, alpha: 1)
            fuelBarIcon.fontColor = .white
        default:
            fuelBar.fillColor = UIColor(red: 0.89, green: 0.29, blue: 0.29, alpha: 1) // vermelho
            fuelBarBorder.strokeColor = UIColor(red: 0.89, green: 0.29, blue: 0.29, alpha: 1)
            fuelBarIcon.fontColor = UIColor(red: 0.89, green: 0.29, blue: 0.29, alpha: 1)
        }

        if jetPack.isThrusting && jetPack.currentFuel > 0 {
            spawnLiquidParticle()
        }
    }

    private func spawnLiquidParticle() {
        let dropRadius = CGFloat.random(in: 3...6)
        let drop = SKShapeNode(circleOfRadius: dropRadius)
        drop.fillColor = UIColor(red: 1.0, green: 0.96, blue: 0.85, alpha: 1.0)
        drop.strokeColor = .clear

        let jetpackOffset = CGPoint(x: -28, y: 0)
        let spawnPosition = self.convert(jetpackOffset, from: player)
        drop.position = spawnPosition

        drop.physicsBody = SKPhysicsBody(circleOfRadius: dropRadius)
        drop.physicsBody?.isDynamic = true
        drop.physicsBody?.categoryBitMask = GameConstants.PhysicsCategory.particle
        drop.physicsBody?.collisionBitMask = 0
        drop.physicsBody?.contactTestBitMask = 0

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
        let masks: [UInt32] = [GameConstants.PhysicsCategory.obstacle,
                               GameConstants.PhysicsCategory.projectile]
        if masks.contains(contact.bodyA.categoryBitMask) { return contact.bodyA.node }
        if masks.contains(contact.bodyB.categoryBitMask) { return contact.bodyB.node }
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
        jetpackHapticAccumulator = 0

        worldNode.children.filter { $0.physicsBody?.categoryBitMask == GameConstants.PhysicsCategory.projectile }.forEach { $0.removeFromParent() }

        if let bossNode = worldNode.childNode(withName: "boss") {
            removeBossEntity(for: bossNode)
            bossNode.removeFromParent()
        }

        player.physicsBody?.categoryBitMask = GameConstants.PhysicsCategory.player
        player.physicsBody?.isDynamic = true
        player.position.x = fixedPlayerX
        player.physicsBody?.velocity = .zero
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 80))

        isGameOver = false
        lastUpdateTime = 0
    }
    
    // MARK: - Colisões
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        // partícula continua síncrona — é só remoção, sem ECS
        if collision == (GameConstants.PhysicsCategory.particle | GameConstants.PhysicsCategory.ground) {
            let particleNode = contact.bodyA.categoryBitMask == GameConstants.PhysicsCategory.particle
                ? contact.bodyA.node
                : contact.bodyB.node
            particleNode?.removeFromParent()
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            switch CollisionHandler.handle(contact) {
            case .groundTouched:
                isGrounded = true
                if let entity = playerEntity, var jetPack = ecsWorld.component(JetPackComponent.self, for: entity) {
                    jetPack.isRecharging = true
                    ecsWorld.addComponent(jetPack, to: entity)
                }

            case .groundLeft:
                isGrounded = false
                if let entity = playerEntity, var jetPack = ecsWorld.component(JetPackComponent.self, for: entity) {
                    jetPack.isRecharging = false
                    ecsWorld.addComponent(jetPack, to: entity)
                }

            case .obstacleHit:
                let obstacleNode = obstacleNode(from: contact)
                gameOver(hitObstacleNode: obstacleNode)

            case .none:
                break
            }
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if collision == (GameConstants.PhysicsCategory.player | GameConstants.PhysicsCategory.ground) {
            DispatchQueue.main.async { [weak self] in
                self?.isPlayerOnGround = false
            }
        }

        switch CollisionHandler.handleEnd(contact) {
        case .groundLeft:
            if let entity = playerEntity, var jetPack = ecsWorld.component(JetPackComponent.self, for: entity) {
                jetPack.isRecharging = false
                ecsWorld.addComponent(jetPack, to: entity)
            }
        default:
            break
        }
    }

    private func gameOver(hitObstacleNode: SKNode?) {
        guard !isGameOver else { return }

        isGameOver = true
        lastHitObstacleNode = hitObstacleNode
        jetpackHapticAccumulator = 0

        player.physicsBody?.categoryBitMask = 0
        player.physicsBody?.velocity = .zero
        player.physicsBody?.isDynamic = false

        if let hitNode = hitObstacleNode {
            hitNode.removeAllActions()
            hitNode.physicsBody?.velocity = .zero
            hitNode.physicsBody?.isDynamic = false
        }

        worldNode.childNode(withName: "boss")?.removeAllActions()

        removeAction(forKey: "spawnObstacles")
        removeAction(forKey: "spawnAerialObstacles")
        removeAction(forKey: "spawnBoss")
        LocalScoreStore.shared.saveIfNeeded(score: score)
        onGameOver?(score)
    }

    func restartGame() {
        isGameOver = false
        score = 0
        currentScenarioSpeed = GameConstants.Physics.scenarioSpeed
        currentPhase = 1
        scoreAccumulator = 0
        obstacleSpawnAccumulator = 0
        bossSpawnAccumulator = 0
        jetpackHapticAccumulator = 0
        
        worldNode.removeAllChildren()
        groundPieces.removeAll()
        player.removeFromParent()
        removeAllActions()
        lastUpdateTime = 0
        fuelBar.removeFromParent()
        fuelBarIcon?.removeFromParent()

        ecsWorld = World()
        scrollSystem = ScrollSystem(scenarioSpeed: GameConstants.Physics.scenarioSpeed)
        
        childNode(withName: "physicsGround")?.removeFromParent() // ← adicione isso
        
        background.reset(in: size)
        setupGround()
        setupPhysicsGround()
        setupPlayer()
        gameHUD.update(score: score, bestScore: LocalScoreStore.shared.bestScore)
        prepareHaptics()
    }
}

// MARK: - Haptics
private extension GameScene {
    func prepareHaptics() {
        guard isHapticsEnabled else { return }
        jumpHaptic.prepare()
        jetpackHaptic.prepare()
        hitHaptic.prepare()
    }

    func triggerJumpHaptic() {
        guard isHapticsEnabled else { return }
        jumpHaptic.impactOccurred(intensity: 0.75)
        jumpHaptic.prepare()
    }

    func triggerJetpackHaptic() {
        guard isHapticsEnabled else { return }
        jetpackHaptic.impactOccurred(intensity: 0.45)
        jetpackHaptic.prepare()
    }

    func triggerHitHaptic() {
        guard isHapticsEnabled else { return }
        hitHaptic.notificationOccurred(.error)
        hitHaptic.prepare()
    }

    func updateJetpackHaptics(deltaTime: TimeInterval) {
        guard let entity = playerEntity,
              let jetPack = ecsWorld.component(JetPackComponent.self, for: entity) else { return }

        guard jetPack.isThrusting, jetPack.currentFuel > 0 else {
            jetpackHapticAccumulator = 0
            return
        }

        jetpackHapticAccumulator += deltaTime

        if jetpackHapticAccumulator >= jetpackHapticInterval {
            jetpackHapticAccumulator = 0
            triggerJetpackHaptic()
        }
    }
}
