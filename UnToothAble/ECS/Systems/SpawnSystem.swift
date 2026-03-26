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
    /// Cooldown após a fada sair antes de spawnar outra (em segundos)
    private let bossCooldown: TimeInterval = 18.0
    private var bossTimer: TimeInterval = 0
    /// Só começa a contar quando a cena chegar no nível certo
    private var bossEnabled: Bool = false
    /// Impede sobreposição: só spawna uma fada de cada vez
    private var isBossActive: Bool = false

    // MARK: - Scene readiness (boss começa após Scene5→6 transição)
    /// Fornecido pela ScrollingBackground via callback
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

    func reset() {
        obstacleSpawnAccumulator = 0
        currentObstacleSpawnInterval = 2.0
        bossTimer = 0
        isBossActive = false
        // Nota: bossUnlocked NÃO é resetado aqui.
        // continueRun() preserva o estado do nível atual.
        // Só restartGame() recria o SpawnSystem do zero.
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
        // Boss só está disponível após o nível de rua (Scene 5→6)
        guard bossUnlocked else { return }
        // Não spawna se já há uma fada ativa
        guard !isBossActive else { return }

        bossTimer += deltaTime
        if bossTimer >= bossCooldown {
            bossTimer = 0
            spawnBoss(world: world, isGameOver: isGameOver)
        }
    }

    // MARK: - Boss Spawn & Behavior

    func spawnBoss(world: World, isGameOver: Bool) {
        guard !isGameOver, !isBossActive, let scene = scene else { return }

        isBossActive = true

        // A fada é filha direta da CENA (não do worldNode) para garantir
        // coordenadas simples e independentes do scroll dos obstáculos.
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

        // Fada é filha da CENA para ter coordenadas fixas (não afetada pelo scroll)
        scene.addChild(boss)

        let entity = BossFactory.create(in: world)
        world.addComponent(SpriteComponent(node: boss), to: entity)

        startBossBehavior(for: boss, world: world)
    }

    private func startBossBehavior(for boss: SKNode, world: World) {
        guard let scene = scene else { return }

        let sceneH = scene.size.height
        let sceneW = scene.size.width

        // Posição X onde a fada fica durante o ataque (canto direito da tela)
        let combatX: CGFloat = sceneW * 0.82

        // Limites verticais de patrulha
        let patrolTop: CGFloat    = sceneH * 0.80
        let patrolBottom: CGFloat = sceneH * 0.30

        // --- Movimento vertical em loop (moveBy para não conflitar com moveTo(x:)) ---
        // A fada f começa em entryY (75% da tela). Patrulha entre +amplitude e -amplitude.
        let amplitude: CGFloat = sceneH * 0.22
        let moveToCombat = SKAction.moveTo(x: combatX, duration: 0.9)
        moveToCombat.timingMode = .easeOut
        
        // Movimento vertical usando group no ciclo principal para sincronizar tudo
        let patrolDown = SKAction.moveBy(x: 0, y: -amplitude, duration: 1.6)
        patrolDown.timingMode = .easeInEaseOut
        let patrolUp = SKAction.moveBy(x: 0, y: amplitude, duration: 1.6)
        patrolUp.timingMode = .easeInEaseOut
        boss.run(.repeatForever(.sequence([patrolDown, patrolUp])), withKey: "bossVertical")

        // --- Fase de ataque: disparos com quantidade e velocidade variável ---
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

        // Pequeno delay extra após o último tiro antes de sair
        shotActions.append(SKAction.wait(forDuration: 0.8))
        let attackPhase = SKAction.sequence(shotActions)

        // --- Saída: desliza para fora da tela ---
        let moveOut = SKAction.moveTo(x: sceneW + 150, duration: 0.9)
        moveOut.timingMode = .easeIn

        // --- Limpeza: remove node, entidade e reset do flag ---
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

    private func spawnBossProjectile(from bossPosition: CGPoint, in scene: SKScene) {
        // Projéteis também são filhos da CENA para coordenadas consistentes
        let speed = CGFloat.random(in: 350...600) // velocidade variável px/s
        let travelDistance = bossPosition.x + 80   // distância até sair pela esquerda

        let projectile = SKSpriteNode(imageNamed: GameConstants.Assets.fairyAttack)
        projectile.size = CGSize(width: 80, height: 80)

        // Posição de lançamento: ligeiramente à esquerda da fada, na altura atual dela
        projectile.position = CGPoint(x: bossPosition.x - 60, y: bossPosition.y)
        projectile.zPosition = 9

        projectile.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        projectile.physicsBody?.isDynamic = false
        projectile.physicsBody?.categoryBitMask = GameConstants.PhysicsCategory.projectile
        projectile.physicsBody?.contactTestBitMask = GameConstants.PhysicsCategory.player
        projectile.physicsBody?.collisionBitMask = GameConstants.PhysicsCategory.player

        scene.addChild(projectile)

        // Duração baseada na velocidade para parecer consistente com o scroll
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

    func forceClearBoss(world: World, scene: SKScene) {
        // Limpa a fada quando o jogador morre ou usa continueRun
        if let bossNode = scene.childNode(withName: "boss") {
            removeBossEntity(for: bossNode, world: world)
            bossNode.removeAllActions()
            bossNode.removeFromParent()
        }
        // Remove projéteis da fada (filhos da cena com categoria projectile)
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
