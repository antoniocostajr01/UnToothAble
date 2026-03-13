//
//  GameScene.swift
//  POCcollision
//
//  Created by sofia leitao on 12/03/26.
//
import SpriteKit

final class GameScene: SKScene, SKPhysicsContactDelegate { //skphysics detecta colisao (chao e obstaculo)
    
    struct PhysicsCategory {
        static let player: UInt32 = 1 << 0 //player eh 1 (0001. desloca o 1 0 casas
        static let ground: UInt32 = 1 << 1 //chao eh 2 (0010). desloca o 1 1 casa
        static let obstacle: UInt32 = 1 << 2 //obstaculo eh 4 (0100). desloca o 1 2 casas
        //diferentes bitmasks para poder detectar colisao de game over
    }
    
    private let worldNode = SKNode() //o que vai mover
    private let player = SKShapeNode(circleOfRadius: 25)
    
    private var groundPieces: [SKSpriteNode] = []
    private var isGameOver = false
    private var canJump = true
    
    private let scenarioSpeed: CGFloat = 250
    private var lastUpdateTime: TimeInterval = 0 //calcula o deltaT entre os frames p movimento ficar constante
    
    private var score: Int = 0 //1pt a cada 1seg que o player fica vivo (mudar para metros depois)
    private var scoreAccumulator: TimeInterval = 0
       
    private let scoreLabel = SKLabelNode(fontNamed: "Avenir-Heavy")
    private let bestScoreLabel = SKLabelNode(fontNamed: "Avenir-Heavy")
    
    override func didMove(to view: SKView) { //inicio
        size = view.bounds.size
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -30) //puxa p baixo
        physicsWorld.contactDelegate = self
        
        addChild(worldNode)
        
        setupGround()
        setupPhysicsGround()
        setupPlayer()
        setupHUD()
        refreshHUD()
        startSpawningObstacles()
    }
    
    private func setupGround() { //
        let groundHeight: CGFloat = 60
        let groundY: CGFloat = 120 //altura y=120
        
        for i in 0..<2 { //cria 2 blocos
            let ground = SKSpriteNode(
                color: .systemGreen,
                size: CGSize(width: size.width, height: groundHeight)
            )
            
            ground.position = CGPoint(
                x: size.width / 2 + CGFloat(i) * size.width, //conecta os blocos um do lado do outro
                y: groundY
            )
            
            worldNode.addChild(ground)
            groundPieces.append(ground)//guarda no array para usar depois
        }
    }
    
    //se o chao estiver sempre se movendo, pode afetar o player com tremor, escorregar etc. entao se cria um invisivel
    private func setupPhysicsGround() {
        let groundHeight: CGFloat = 60
        let groundY: CGFloat = 120
        
        let physicsGround = SKNode() //cria um chao invisivel na mesma linha do verde para o player cair em cima
        physicsGround.position = CGPoint(x: size.width / 2, y: groundY)
        physicsGround.physicsBody = SKPhysicsBody(
            rectangleOf: CGSize(width: size.width * 2, height: groundHeight)
        )
        physicsGround.physicsBody?.isDynamic = false
        physicsGround.physicsBody?.categoryBitMask = PhysicsCategory.ground
        physicsGround.physicsBody?.contactTestBitMask = PhysicsCategory.player //player encosta nele
        physicsGround.physicsBody?.collisionBitMask = PhysicsCategory.player //pode colidir com ele
        
        addChild(physicsGround)
    }
    
    private func setupPlayer() {
        player.fillColor = .systemBlue
        player.strokeColor = .clear
        
        player.position = CGPoint(x: size.width * 0.25, y: 180) //mais a esquerda em 25% da tela no x
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: 25) //fisica circular
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.restitution = 0 //nao quica, =1 quica bastante
        player.physicsBody?.friction = 1
        player.physicsBody?.linearDamping = 0 //sem desaceleracao
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.obstacle | PhysicsCategory.ground //toca ou chao ou obstaculo
        player.physicsBody?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.obstacle //colide com chao e obstaculo
        
        addChild(player)
    }
    
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
    
    
    private func startSpawningObstacles() {
        let spawn = SKAction.run { [weak self] in //weak self evita retencao de memoria
            self?.spawnObstacle() //executa spawnObstacle()
        }
        let wait = SKAction.wait(forDuration: 1.8) //tempo entre spawn
        let sequence = SKAction.sequence([spawn, wait]) //sequencia entre spawn, espera, spawn, espera etc
        run(.repeatForever(sequence), withKey: "spawnObstacles") //repete infinitamente
    }
    
    private func spawnObstacle() {
        if isGameOver { return } //se gameover sai da func
        
        let obstacle = SKSpriteNode(color: .systemRed, size: CGSize(width: 30, height: 55))
        obstacle.position = CGPoint(x: size.width + 60, y: 150) //x: nasce a direita da tela pra dar impressao de que vem de fora, y: acima do chao (aumentar)
        
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
        obstacle.physicsBody?.isDynamic = false //nao sofre nada
        obstacle.physicsBody?.categoryBitMask = PhysicsCategory.obstacle //eh obstculo
        obstacle.physicsBody?.contactTestBitMask = PhysicsCategory.player //quer contato com player
        obstacle.physicsBody?.collisionBitMask = PhysicsCategory.player //colide com player
        
        worldNode.addChild(obstacle) //faz andar junto com o cenario
    }
    
    private func jump() {
        if !canJump || isGameOver { return } //nao pode pular ou gameover = nao pula
        
        canJump = false //se esta pulando nao pula dnv
        player.physicsBody?.velocity = CGVector(dx: 0, dy: 0) //limpa velocidade antes do impulso p nao acumular
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 120))//quanto vai para cima
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { //se acabou reinicia se nao pula
        if isGameOver {
            restartGame()
        } else {
            jump()
        }
    }
    
    //movement = speed * deltaTime garante movimento consistente
    override func update(_ currentTime: TimeInterval) { //roda a cada frame do jogo, loop principal
        var deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime //calcula quanto tempo teve entre o ultimo frame e o atual
        
        if deltaTime > 1 {
            deltaTime = 1.0 / 60.0 //1 frame a 60 FPS
        }
        
        guard !isGameOver else { return } //se acabou nao continua andando
        
        scoreAccumulator += deltaTime
        if scoreAccumulator >= 1 {
          score += 1
          scoreAccumulator = 0
          refreshHUD()
        }
        
        moveScenario(deltaTime: deltaTime)
        recycleGround()//recicla chao infinito
        removeOffscreenObstacles()//remove os obstaculos que ficaram na tela
    }
    
    private func moveScenario(deltaTime: TimeInterval) {
        let moveX = scenarioSpeed * CGFloat(deltaTime) //aprox 4 pontos por frame
        
        for node in worldNode.children {
            node.position.x -= moveX //tudo do world node move
        }
    }
    
    private func recycleGround() {
        //se o centro do chao ja passou da metade da largura para fora da esquerda ele saiu completamente da tela
        for ground in groundPieces {
            if ground.position.x < -ground.size.width / 2 {
                let rightMostX = groundPieces.map(\.position.x).max() ?? 0 //identifica qual eh o mais a frente
                ground.position.x = rightMostX + ground.size.width //move o que saiu para logo depois do último
            }
        }
    }
    
    private func removeOffscreenObstacles() {
        //remove o no se ele nao for um dos pedacos do chao ou ja estiver bem fora da tela
        for node in worldNode.children {
            if !groundPieces.contains(where: { $0 == node }) && node.position.x < -100 {
                node.removeFromParent() //remove da cena
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let categories = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask //combina os bitmasks dos dois corpos sem importar a ordem player+obs ou obs+player
        
        if categories == PhysicsCategory.player | PhysicsCategory.ground {
            canJump = true
        }//encosta no chao pode pular novamente.
        
        if categories == PhysicsCategory.player | PhysicsCategory.obstacle {
            gameOver()
        }//encosta no obstaculo chama gameover
    }
    
    private func gameOver() {
        isGameOver = true
        removeAction(forKey: "spawnObstacles") //para de spawn obs
        
        LocalScoreStore.shared.saveIfNeeded(score: score)
        refreshHUD()
        
        if childNode(withName: "gameOverLabel") == nil { //cria o texto se ele ainda nao existir
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
        //volta ao estado normal
        
        childNode(withName: "gameOverLabel")?.removeFromParent() //tira a label de gameover
        
        worldNode.removeAllChildren() //remove chao verde e obs
        groundPieces.removeAll() //limpa o array dos blocos de chao
        player.removeFromParent() //remove o player da cena
        removeAllActions() //remove acoes em execucao tipo spawn
        
        lastUpdateTime = 0 //zera o calculo do deltaT
        
        setupGround()
        setupPhysicsGround()
        setupPlayer()
        refreshHUD()
        startSpawningObstacles()
        //recria o jogo
    }
}
