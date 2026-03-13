//
//  GameScene.swift
//  POCcollision
//
//  Created by sofia leitao on 12/03/26.
//
import SpriteKit

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    struct PhysicsCategory {
        static let player: UInt32 = 1 << 0
        static let ground: UInt32 = 1 << 1
        static let obstacle: UInt32 = 1 << 2
    }
    
    // NÓS DA CENA
    private let worldNode = SKNode()
    private let player = SKSpriteNode(imageNamed: "Tooth") // Usando o Sprite do dente
    
    // A tua nova entidade independente para o Fundo
    private let background = ScrollingBackground()
    
    // VARIÁVEIS DE ESTADO
    private var groundPieces: [SKSpriteNode] = []
    private var isGameOver = false
    private var canJump = true
    
    private let scenarioSpeed: CGFloat = 250
    private var lastUpdateTime: TimeInterval = 0
    
    // PONTUAÇÃO
    private var score: Int = 0
    private var scoreAccumulator: TimeInterval = 0
       
    private let scoreLabel = SKLabelNode(fontNamed: "Avenir-Heavy")
    private let bestScoreLabel = SKLabelNode(fontNamed: "Avenir-Heavy")
    
    // MARK: - Inicialização
    override func didMove(to view: SKView) {
        size = view.bounds.size
        backgroundColor = .clear // Fundo transparente para o ScrollingBackground aparecer
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -30) // Gravidade a puxar para baixo
        physicsWorld.contactDelegate = self
        
        // 1. Adiciona e configura o Background na cena principal (fica atrás de tudo)
        addChild(background)
        background.setup(in: size)
        
        // 2. Adiciona o worldNode (onde os obstáculos e o chão se vão mover)
        addChild(worldNode)
        
        // 3. Configura os restantes elementos
        setupGround()
        setupPhysicsGround()
        setupPlayer()
        setupHUD()
        refreshHUD()
        startSpawningObstacles()
    }
    
    // MARK: - Configuração de Elementos
    private func setupGround() {
        let groundHeight: CGFloat = 60
        let groundY: CGFloat = 120 // Altura base
        
        for i in 0..<2 {
            let ground = SKSpriteNode(color: .systemGreen, size: CGSize(width: size.width, height: groundHeight))
            
            ground.position = CGPoint(
                x: size.width / 2 + CGFloat(i) * size.width,
                y: groundY
            )
            
            worldNode.addChild(ground)
            groundPieces.append(ground)
        }
    }
    
    private func setupPhysicsGround() {
        let groundHeight: CGFloat = 60
        let groundY: CGFloat = 120
        
        let physicsGround = SKNode()
        physicsGround.position = CGPoint(x: size.width / 2, y: groundY)
        physicsGround.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 2, height: groundHeight))
        physicsGround.physicsBody?.isDynamic = false
        physicsGround.physicsBody?.categoryBitMask = PhysicsCategory.ground
        physicsGround.physicsBody?.contactTestBitMask = PhysicsCategory.player
        physicsGround.physicsBody?.collisionBitMask = PhysicsCategory.player
        
        addChild(physicsGround)
    }
    
    private func setupPlayer() {
        // Redimensiona a imagem do dente
        player.size = CGSize(width: 70, height: 70)
        player.position = CGPoint(x: size.width * 0.25, y: 180)
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: 25)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.restitution = 0
        player.physicsBody?.friction = 1
        player.physicsBody?.linearDamping = 0
        
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.obstacle | PhysicsCategory.ground
        player.physicsBody?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.obstacle
        
        addChild(player)
    }
    
    // MARK: - HUD (Interface)
    private func setupHUD() {
        scoreLabel.fontSize = 26
        scoreLabel.fontColor = .black
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 20, y: size.height - 60)
        addChild(scoreLabel)
        
        bestScoreLabel.fontSize = 22
        bestScoreLabel.fontColor = .darkGray
        bestScoreLabel.horizontalAlignmentMode = .left
        bestScoreLabel.position = CGPoint(x: 20, y: size.height - 95)
        addChild(bestScoreLabel)
    }
    
    private func refreshHUD() {
        scoreLabel.text = "Score: \(score)"
        bestScoreLabel.text = "Best: \(LocalScoreStore.shared.bestScore)"
    }
    
    // MARK: - Obstáculos e Controlos
    private func startSpawningObstacles() {
        let spawn = SKAction.run { [weak self] in
            self?.spawnObstacle()
        }
        let wait = SKAction.wait(forDuration: 1.8)
        let sequence = SKAction.sequence([spawn, wait])
        run(.repeatForever(sequence), withKey: "spawnObstacles")
    }
    
    private func spawnObstacle() {
        if isGameOver { return }
        
        let obstacle = SKSpriteNode(color: .systemRed, size: CGSize(width: 30, height: 55))
        obstacle.position = CGPoint(x: size.width + 60, y: 150)
        
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
        obstacle.physicsBody?.isDynamic = false
        obstacle.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        obstacle.physicsBody?.contactTestBitMask = PhysicsCategory.player
        obstacle.physicsBody?.collisionBitMask = PhysicsCategory.player
        
        worldNode.addChild(obstacle)
    }
    
    private func jump() {
        if !canJump || isGameOver { return }
        
        canJump = false
        player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 120))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver {
            restartGame()
        } else {
            jump()
        }
    }
    
    // MARK: - Game Loop Principal
    override func update(_ currentTime: TimeInterval) {
        var deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        // Limita o deltaTime a 60 FPS em caso de lag
        if deltaTime > 1 { deltaTime = 1.0 / 60.0 }
        
        guard !isGameOver else { return } // Impede o cenário e o fundo de andarem se o jogador perdeu
        
        // Atualiza a Pontuação
        scoreAccumulator += deltaTime
        if scoreAccumulator >= 1 {
          score += 1
          scoreAccumulator = 0
          refreshHUD()
        }
        
        // Move o chão e os obstáculos
        moveScenario(deltaTime: deltaTime)
        recycleGround()
        removeOffscreenObstacles()
        
        // DELEGA O MOVIMENTO DO FUNDO À NOVA ENTIDADE
        background.update(deltaTime: deltaTime, scenarioSpeed: scenarioSpeed)
    }
    
    private func moveScenario(deltaTime: TimeInterval) {
        let moveX = scenarioSpeed * CGFloat(deltaTime)
        
        // Move apenas os filhos do worldNode (chão e obstáculos)
        for node in worldNode.children {
            node.position.x -= moveX
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
        for node in worldNode.children {
            if !groundPieces.contains(where: { $0 == node }) && node.position.x < -100 {
                node.removeFromParent()
            }
        }
    }
    
    // MARK: - Colisões e Estado do Jogo
    func didBegin(_ contact: SKPhysicsContact) {
        let categories = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        // Contacto com o chão: permite saltar novamente
        if categories == PhysicsCategory.player | PhysicsCategory.ground {
            canJump = true
        }
        
        // Contacto com o obstáculo: fim de jogo
        if categories == PhysicsCategory.player | PhysicsCategory.obstacle {
            gameOver()
        }
    }
    
    private func gameOver() {
        isGameOver = true
        removeAction(forKey: "spawnObstacles")
        
        LocalScoreStore.shared.saveIfNeeded(score: score)
        refreshHUD()
        
        if childNode(withName: "gameOverLabel") == nil {
            let label = SKLabelNode(text: "Game Over - toque para reiniciar")
            label.name = "gameOverLabel"
            label.fontName = "Avenir-Heavy"
            label.fontSize = 24
            label.fontColor = .black
            label.position = CGPoint(x: size.width / 2, y: size.height - 120)
            addChild(label)
        }
    }
    
    private func restartGame() {
        isGameOver = false
        canJump = true
        score = 0
        scoreAccumulator = 0
        
        childNode(withName: "gameOverLabel")?.removeFromParent()
        
        // Limpa tudo
        worldNode.removeAllChildren()
        groundPieces.removeAll()
        player.removeFromParent()
        removeAllActions()
        
        lastUpdateTime = 0
        
        // Dá o comando à entidade para reiniciar o fundo
        background.reset(in: size)
        
        // Recria a cena
        setupGround()
        setupPhysicsGround()
        setupPlayer()
        refreshHUD()
        startSpawningObstacles()
    }
}
