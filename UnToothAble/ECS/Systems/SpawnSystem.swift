//
//  SpawnSystem.swift
//  UnToothAble
//
//  ECS: Manages obstacle, aerial obstacle, and boss spawning timers.
//

import SpriteKit

final class SpawnSystem {

    // MARK: - Ground obstacle spawn
    private var obstacleSpawnAccumulator: TimeInterval = 0
    private var currentObstacleSpawnInterval: TimeInterval = 2.0
    private let minObstacleGap: TimeInterval = 3.5
    private let maxObstacleGap: TimeInterval = 6.0

    // MARK: - Boss spawn
    private let bossCooldown: TimeInterval = 18.0
    private var bossTimer: TimeInterval = 0
    private var bossEnabled: Bool = false
    /// `true` enquanto a fada estiver em cena; impede sobreposição de spawns.
    private var isBossActive: Bool = false

    /// Liberado pela `ScrollingBackground` ao atingir a transição Scene5→6.
    var bossUnlocked: Bool = false

    // MARK: - References
    private weak var worldNode: SKNode?
    private weak var scene: SKScene?
    private var currentPhase: () -> Int
    private var scenarioSpeed: () -> CGFloat

    init(worldNode: SKNode,
         scene: SKScene,
         currentPhase: @escaping () -> Int,
         scenarioSpeed: @escaping () -> CGFloat) {
        self.worldNode = worldNode
        self.scene = scene
        self.currentPhase = currentPhase
        self.scenarioSpeed = scenarioSpeed
    }

    /// Reseta timers e flags de spawn. `bossUnlocked` é preservado — apenas `restartGame()`,
    /// que recria o `SpawnSystem`, volta esse flag para `false`.
    func reset() {
        obstacleSpawnAccumulator = 0
        currentObstacleSpawnInterval = 2.0
        bossTimer = 0
        isBossActive = false
    }

    func update(world: World, deltaTime: TimeInterval, isGameOver: Bool) {
        guard !isGameOver else { return }

        updateObstacleSpawn(world: world, deltaTime: deltaTime)
        updateBossTimer(world: world, deltaTime: deltaTime, isGameOver: isGameOver)
    }

    // MARK: - Ground Obstacles

    private func updateObstacleSpawn(world: World, deltaTime: TimeInterval) {
        obstacleSpawnAccumulator += deltaTime

        if obstacleSpawnAccumulator >= currentObstacleSpawnInterval {
            obstacleSpawnAccumulator = 0
            spawnObstacle(world: world)
            currentObstacleSpawnInterval = TimeInterval.random(in: minObstacleGap...maxObstacleGap)
        }
    }

    func spawnObstacle(world: World) {
        guard let worldNode = worldNode, let scene = scene else { return }

        let obstacleTextures = currentObstacleTextures()
        let obstacle = SKSpriteNode(texture: obstacleTextures[0])
        obstacle.size = CGSize(width: 100, height: 100)

        let spawnPosition = CGPoint(x: scene.size.width + 60, y: 90)
        obstacle.position = spawnPosition

        let obstacleAnimation = SKAction.animate(with: obstacleTextures, timePerFrame: 0.15)
        obstacle.run(.repeatForever(obstacleAnimation), withKey: "obstacleAnimation")

        obstacle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 60))
        obstacle.physicsBody?.isDynamic = false
        obstacle.physicsBody?.categoryBitMask = GameConstants.PhysicsCategory.obstacle
        obstacle.physicsBody?.contactTestBitMask = GameConstants.PhysicsCategory.player
        obstacle.physicsBody?.collisionBitMask = GameConstants.PhysicsCategory.player

        worldNode.addChild(obstacle)

        let entity = ObstacleFactory.create(in: world, at: spawnPosition)
        world.addComponent(SpriteComponent(node: obstacle), to: entity)
    }

    // MARK: - Aerial Obstacles

    func startSpawningAerialObstacles() {
        spawnAerialObstacleLoop()
    }

    private func spawnAerialObstacleLoop() {
        guard let scene = scene else { return }

        let randomWait = TimeInterval.random(in: 3.0...8.0)
        let wait = SKAction.wait(forDuration: randomWait)
        let spawn = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.spawnAerialObstacle()
            self.spawnAerialObstacleLoop()
        }

        scene.run(.sequence([wait, spawn]), withKey: "spawnAerialObstacles")
    }

    private func spawnAerialObstacle() {
        guard let worldNode = worldNode, let scene = scene else { return }

        let aerialObstacle = SKSpriteNode(imageNamed: GameConstants.Assets.flyingObstacleFrame1)
        aerialObstacle.name = "aerialObstacle"
        aerialObstacle.size = CGSize(width: 100, height: 100)

        let minY = GameConstants.Layout.groundBaseY + 80
        let maxY = scene.size.height - 50
        let randomY = CGFloat.random(in: minY...maxY)
        let randomX = scene.size.width + CGFloat.random(in: 100...600)

        let spawnPosition = CGPoint(x: randomX, y: randomY)
        aerialObstacle.position = spawnPosition

        let texture1 = SKTexture(imageNamed: GameConstants.Assets.flyingObstacleFrame1)
        let texture2 = SKTexture(imageNamed: GameConstants.Assets.flyingObstacleFrame2)
        let flapAnimation = SKAction.animate(with: [texture1, texture2], timePerFrame: 0.2)
        aerialObstacle.run(.repeatForever(flapAnimation), withKey: "aerialFlap")

        aerialObstacle.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        aerialObstacle.physicsBody?.isDynamic = false
        aerialObstacle.physicsBody?.categoryBitMask = GameConstants.PhysicsCategory.obstacle
        aerialObstacle.physicsBody?.contactTestBitMask = GameConstants.PhysicsCategory.player
        aerialObstacle.physicsBody?.collisionBitMask = GameConstants.PhysicsCategory.player

        worldNode.addChild(aerialObstacle)

        let world = (scene as? GameScene)?.ecsWorld
        if let world = world {
            let entity = ObstacleFactory.create(in: world, at: spawnPosition)
            world.addComponent(SpriteComponent(node: aerialObstacle), to: entity)
        }
    }

    // MARK: - Boss Timer

    private func updateBossTimer(world: World, deltaTime: TimeInterval, isGameOver: Bool) {
        guard bossUnlocked, !isBossActive else { return }

        bossTimer += deltaTime
        if bossTimer >= bossCooldown {
            bossTimer = 0
            spawnBoss(world: world, isGameOver: isGameOver)
        }
    }

    // MARK: - Boss Spawn & Behavior

    /// Spawna a fada diretamente na cena (não no `worldNode`) para que
    /// suas coordenadas sejam independentes do scroll dos obstáculos.
    func spawnBoss(world: World, isGameOver: Bool) {
        guard !isGameOver, !isBossActive, let scene = scene else { return }

        isBossActive = true

        let startX = scene.size.width + 120
        let entryY = scene.size.height * 0.75

        let boss = SKSpriteNode(imageNamed: GameConstants.Assets.bossFrame1)
        boss.name = "boss"
        boss.size = CGSize(width: 180, height: 180)
        boss.position = CGPoint(x: startX, y: entryY)
        boss.zPosition = 10

        let texture1 = SKTexture(imageNamed: GameConstants.Assets.bossFrame1)
        let texture2 = SKTexture(imageNamed: GameConstants.Assets.bossFrame2)
        let flapAnimation = SKAction.animate(with: [texture1, texture2], timePerFrame: 0.2)
        boss.run(.repeatForever(flapAnimation), withKey: "bossFlap")

        scene.addChild(boss)

        let entity = BossFactory.create(in: world)
        world.addComponent(SpriteComponent(node: boss), to: entity)

        startBossBehavior(for: boss, world: world)
    }

    private func startBossBehavior(for boss: SKNode, world: World) {
        guard let scene = scene else { return }

        let sceneH = scene.size.height
        let sceneW = scene.size.width

        let combatX: CGFloat = sceneW * 0.82

        // Patrulha vertical entre o chão e o teto, respeitando metade do sprite (90 pt) como margem.
        let groundFloor: CGFloat = GameConstants.Layout.groundBaseY
            + GameConstants.Layout.groundHeight + 90 + 15
        let ceilingY: CGFloat = sceneH - 90 - 15

        let sweepDown = SKAction.moveTo(y: groundFloor, duration: 2.2)
        sweepDown.timingMode = .easeInEaseOut
        let sweepUp = SKAction.moveTo(y: ceilingY, duration: 2.2)
        sweepUp.timingMode = .easeInEaseOut
        boss.run(.repeatForever(.sequence([sweepDown, sweepUp])), withKey: "bossVertical")

        let moveToCombat = SKAction.moveTo(x: combatX, duration: 1.2)
        (moveToCombat as SKAction).timingMode = .easeOut

        let shotCount = Int.random(in: 3...7)
        var shotActions: [SKAction] = []

        for _ in 0..<shotCount {
            let waitBetween = SKAction.wait(forDuration: TimeInterval.random(in: 1.0...2.2))
            let shoot = SKAction.run { [weak self, weak boss] in
                guard let self = self, let boss = boss else { return }
                self.spawnBossProjectile(from: boss.position, in: scene)
            }
            shotActions.append(contentsOf: [waitBetween, shoot])
        }

        shotActions.append(SKAction.wait(forDuration: 0.8))
        let attackPhase = SKAction.sequence(shotActions)

        let moveOut = SKAction.moveTo(x: sceneW + 150, duration: 0.9)
        moveOut.timingMode = .easeIn

        let cleanup = SKAction.run { [weak self, weak boss] in
            guard let self = self, let boss = boss else { return }
            if let world = (scene as? GameScene)?.ecsWorld {
                self.removeBossEntity(for: boss, world: world)
            }
            boss.removeAllActions()
            boss.removeFromParent()
            self.isBossActive = false
        }

        let fullCycle = SKAction.sequence([moveToCombat, attackPhase, moveOut, cleanup])
        boss.run(fullCycle, withKey: "bossMainCycle")
    }

    // MARK: - Projectile

    /// Projéteis são filhos da cena (não do `worldNode`) para coordenadas consistentes com a fada.
    private func spawnBossProjectile(from bossPosition: CGPoint, in scene: SKScene) {
        let speed = CGFloat.random(in: 350...600)
        let travelDistance = bossPosition.x + 80

        let projectile = SKSpriteNode(imageNamed: GameConstants.Assets.fairyAttack)
        projectile.size = CGSize(width: 80, height: 80)
        projectile.position = CGPoint(x: bossPosition.x - 60, y: bossPosition.y)
        projectile.zPosition = 9

        projectile.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        projectile.physicsBody?.isDynamic = false
        projectile.physicsBody?.categoryBitMask = GameConstants.PhysicsCategory.projectile
        projectile.physicsBody?.contactTestBitMask = GameConstants.PhysicsCategory.player
        projectile.physicsBody?.collisionBitMask = GameConstants.PhysicsCategory.player

        scene.addChild(projectile)

        let duration = Double(travelDistance / speed)
        let moveLeft = SKAction.moveBy(x: -travelDistance, y: 0, duration: duration)
        let remove   = SKAction.removeFromParent()
        projectile.run(.sequence([moveLeft, remove]))
    }

    // MARK: - Boss Entity Removal

    func removeBossEntity(for node: SKNode, world: World) {
        let bosses = world.entities(with: [BossComponent.self, SpriteComponent.self])

        for entity in bosses {
            guard let sprite = world.component(SpriteComponent.self, for: entity) else { continue }
            if sprite.node === node {
                world.removeEntity(entity)
                break
            }
        }
    }

    /// Remove a fada e todos os seus projéteis da cena. Chamado em game over e `continueRun`.
    func forceClearBoss(world: World, scene: SKScene) {
        if let bossNode = scene.childNode(withName: "boss") {
            removeBossEntity(for: bossNode, world: world)
            bossNode.removeAllActions()
            bossNode.removeFromParent()
        }
        scene.children
            .filter { $0.physicsBody?.categoryBitMask == GameConstants.PhysicsCategory.projectile }
            .forEach { $0.removeFromParent() }

        isBossActive = false
        bossTimer = 0
    }

    // MARK: - Texture Helpers

    private func currentObstacleTextures() -> [SKTexture] {
        switch currentPhase() {
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
}

