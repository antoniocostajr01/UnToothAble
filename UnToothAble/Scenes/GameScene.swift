//
//  GameScene.swift
//  UnToothAble
//
import SpriteKit
import UIKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - ECS
    var ecsWorld = World()
    private var scrollSystem = ScrollSystem()
    private var jetPackSystem = JetPackSystem()
    private var animationSystem = AnimationSystem()
    private var scoreSystem: ScoreSystem!
    private var spawnSystem: SpawnSystem!
    var fuelBarSystem: FuelBarSystem!
    var groundSystem = GroundSystem()
    private var cleanupSystem = CleanupSystem()
    var playerEntity: Entity?
    
    var gameManager: GameManager?
    
    private var currentScenarioSpeed: CGFloat = GameConstants.Physics.scenarioSpeed
    
    let worldNode = SKNode()
    let player = SKSpriteNode(imageNamed: GameConstants.Assets.playerFrame1)
    private let background = ScrollingBackground()

    var isGameOver = false
    var lastUpdateTime: TimeInterval = 0
    var currentPhase: Int = 1

    private weak var lastHitObstacleNode: SKNode?
    var fixedPlayerX: CGFloat = 0
    private var hasPerformedInitialSetup = false

    var isGrounded: Bool = false

    // MARK: - Haptics
    private let hapticsManager = HapticsManager()

    private let gameHUD = GameHUD()

    var onGameOver: ((Int) -> Void)?
    private var scoreEntity: Entity?

    override func didMove(to view: SKView) {
        size = view.bounds.size
        backgroundColor = .clear

        view.ignoresSiblingOrder = true
        
        physicsWorld.gravity = CGVector(dx: 0, dy: GameConstants.Physics.gravityY)
        physicsWorld.contactDelegate = self
        hapticsManager.resume()

        if hasPerformedInitialSetup {
            return
        }
        hasPerformedInitialSetup = true

        addChild(background)
        background.setup(in: size)

        background.onLevelUp = { [weak self] in
            guard let self = self else { return }
            self.currentScenarioSpeed += GameConstants.Physics.speedIncrement
            self.currentPhase = min(self.currentPhase + 1, 4)
        }

        background.onBossUnlocked = { [weak self] in
            self?.spawnSystem.bossUnlocked = true
        }
        
        addChild(worldNode)

        // Setup systems que precisam de referências da cena
        scoreSystem = ScoreSystem(hud: gameHUD)
        spawnSystem = SpawnSystem(
            worldNode: worldNode,
            scene: self,
            currentPhase: { [weak self] in self?.currentPhase ?? 1 },
            scenarioSpeed: { [weak self] in self?.currentScenarioSpeed ?? GameConstants.Physics.scenarioSpeed }
        )

        setupPhysicsGround()
        setupPlayer()
        warmUpPhysicsAndTextures()
        spawnSystem.startSpawningAerialObstacles()
        gameHUD.addTo(scene: self)
        gameHUD.update(score: 0, bestScore: LocalScoreStore.shared.bestScore)
    }
    
    private func warmUpPhysicsAndTextures() {
        let dummy = SKSpriteNode(color: .clear, size: CGSize(width: 1, height: 1))
        dummy.physicsBody = SKPhysicsBody(circleOfRadius: 1)
        dummy.physicsBody?.categoryBitMask = 0
        dummy.alpha = 0
        addChild(dummy)

        let wait = SKAction.wait(forDuration: 0.1)
        let remove = SKAction.removeFromParent()
        dummy.run(SKAction.sequence([wait, remove]))
    }

    // MARK: - Input

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGameOver else { return }
        
        guard let entity = playerEntity,
              var jetPack = ecsWorld.component(JetPackComponent.self, for: entity) else { return }

        if jetPack.currentFuel >= jetPack.ignitionCost {
            hapticsManager.triggerJump()

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
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    // MARK: - Game Loop

    override func update(_ currentTime: TimeInterval) {
        guard !isPaused, !isGameOver else { return }
        var deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        if deltaTime > 1 {
            deltaTime = 1.0 / 60.0
        }
        
        let currentSpeed = self.currentScenarioSpeed
        
        // 1. Sync SpriteKit → ECS
        syncPlayerPositionFromNode()
        // 2. ECS Systems
        scrollSystem.update(world: ecsWorld, deltaTime: deltaTime, scenarioSpeed: currentSpeed)
        jetPackSystem.update(world: ecsWorld, deltaTime: deltaTime)
        animationSystem.update(world: ecsWorld, deltaTime: deltaTime)
        scoreSystem.update(world: ecsWorld, deltaTime: deltaTime)
        spawnSystem.update(world: ecsWorld, deltaTime: deltaTime, isGameOver: isGameOver)
        cleanupSystem.update(world: ecsWorld)
        // 3. Sync ECS → SpriteKit
        syncPositionToNodes()
        // 4. Visuals
        fuelBarSystem.update(world: ecsWorld, playerEntity: playerEntity)
        groundSystem.update(deltaTime: deltaTime, currentSpeed: currentSpeed)
        background.update(deltaTime: deltaTime, scenarioSpeed: currentSpeed)
        // 5. Haptics
        updateHapticsFromECS(deltaTime: deltaTime)
        // 6. Player constraints
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

    private func updateHapticsFromECS(deltaTime: TimeInterval) {
        guard let entity = playerEntity,
              let jetPack = ecsWorld.component(JetPackComponent.self, for: entity) else { return }
        hapticsManager.updateJetpackHaptics(
            deltaTime: deltaTime,
            isThrusting: jetPack.isThrusting,
            hasFuel: jetPack.currentFuel > 0
        )
    }

    // MARK: - ECS ↔ SpriteKit Sync

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

    // MARK: - Collision helpers

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

    private func removeAllAerialObstacles() {
        worldNode.children
            .filter { $0.name == "aerialObstacle" }
            .forEach {
                $0.removeAllActions()
                $0.removeFromParent()
            }
    }

    // MARK: - Continue / Game Over / Restart

    func continueRun() {
        removeAllObstaclesAheadOfPlayer()
        removeAllAerialObstacles()
        lastHitObstacleNode = nil

        spawnSystem.reset()
        hapticsManager.resume()

        spawnSystem.forceClearBoss(world: ecsWorld, scene: self)

        player.physicsBody?.categoryBitMask = GameConstants.PhysicsCategory.player
        player.physicsBody?.isDynamic = true
        player.position.x = fixedPlayerX
        player.physicsBody?.velocity = .zero
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 80))

        spawnSystem.startSpawningAerialObstacles()

        isGameOver = false
        lastUpdateTime = 0
        hapticsManager.prepare()
    }
    
    // MARK: - Colisões
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

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
                self.hapticsManager.triggerHit()
                let obstacleNode = self.obstacleNode(from: contact)
                self.hapticsManager.stopAll()
                self.gameOver(hitObstacleNode: obstacleNode)

            case .none:
                break
            }
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
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

        player.physicsBody?.categoryBitMask = 0
        player.physicsBody?.velocity = .zero
        player.physicsBody?.isDynamic = false

        if let hitNode = hitObstacleNode {
            hitNode.removeAllActions()
            hitNode.physicsBody?.velocity = .zero
            hitNode.physicsBody?.isDynamic = false
        }

        spawnSystem.forceClearBoss(world: ecsWorld, scene: self)

        removeAction(forKey: "spawnObstacles")
        removeAction(forKey: "spawnAerialObstacles")
        removeAction(forKey: "spawnBoss")

        let finalScore = scoreSystem.currentScore(world: ecsWorld)
        LocalScoreStore.shared.saveIfNeeded(score: finalScore)
        onGameOver?(finalScore)
    }

    func restartGame() {
        isGameOver = false
        currentScenarioSpeed = GameConstants.Physics.scenarioSpeed
        currentPhase = 1

        spawnSystem.forceClearBoss(world: ecsWorld, scene: self)

        worldNode.removeAllChildren()
        player.removeFromParent()
        removeAllActions()
        lastUpdateTime = 0

        ecsWorld = World()
        scrollSystem = ScrollSystem()

        spawnSystem = SpawnSystem(
            worldNode: worldNode,
            scene: self,
            currentPhase: { [weak self] in self?.currentPhase ?? 1 },
            scenarioSpeed: { [weak self] in self?.currentScenarioSpeed ?? GameConstants.Physics.scenarioSpeed }
        )

        childNode(withName: "physicsGround")?.removeFromParent()

        background.onBossUnlocked = { [weak self] in
            self?.spawnSystem.bossUnlocked = true
        }
        background.reset(in: size)
        groundSystem.reset(in: size, worldNode: worldNode)
        setupPhysicsGround()
        setupPlayer()
        spawnSystem.startSpawningAerialObstacles()
        gameHUD.update(score: 0, bestScore: LocalScoreStore.shared.bestScore)
        hapticsManager.resume()
    }

    func stopAllHaptics() {
        hapticsManager.stopAll()

        guard let entity = playerEntity,
              var jetPack = ecsWorld.component(JetPackComponent.self, for: entity) else { return }

        jetPack.isThrusting = false
        ecsWorld.addComponent(jetPack, to: entity)
    }

    func resumeHaptics() {
        hapticsManager.resume()
    }
}
