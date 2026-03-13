//
//  GameScene.swift
//  POC_FisicaPersonagem
//
//  Created by Richard Fagundes Rodrigues on 12/03/26.
//

import SpriteKit

// SKPhysicsContactDelegate é necessário para que a cena escute e responda a colisões físicas
class JetPackPhysics: SKScene, SKPhysicsContactDelegate {

    private var player: SKShapeNode!
    private var jetpack: SKShapeNode!
    private var fuelBar: SKShapeNode!

    // Estado do toque na tela
    private var isTouching: Bool = false

    // applyImpulse: Força explosiva usada uma única vez (o arranque do pulo)
    private let jumpImpulse: CGFloat = 40.0
    // applyForce: Força contínua adicionada a cada frame para vencer a gravidade e voar
    private let hoverForce: CGFloat = 80.0

    // Variáveis de controle de recurso
    private let maxFuel: CGFloat = 100.0
    private var currentFuel: CGFloat = 100.0
    private let fuelConsumptionRate: CGFloat = 1.5 // Gasto constante enquanto voa
    private let ignitionCost: CGFloat = 5.0 // Pedágio para iniciar o voo (evita pulos infinitos sem gastar nada)

    // Bitmasks (Categorias Físicas):
    // Usamos deslocamento de bits (bit shifting) para criar identificadores únicos em base 2.
    // O motor físico usa isso para saber rapidamente quem é quem.
    private let playerCategory: UInt32 = 0x1 << 0   // 1
    private let groundCategory: UInt32 = 0x1 << 1   // 2
    private let particleCategory: UInt32 = 0x1 << 2 // 4

    // didMove é o equivalente ao viewDidLoad. Roda quando a cena é apresentada na tela.
    override func didMove(to view: SKView) {
        self.backgroundColor = .black

        // Avisa ao motor de física que esta classe vai gerenciar os avisos de colisão
        self.physicsWorld.contactDelegate = self

        setupGround()
        setupCeiling()
        setupPlayer()
    }

    private func setupGround() {
        let ground = SKNode()
        ground.position = CGPoint(x: self.frame.midX, y: self.frame.minY)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))

        // isDynamic = false faz com que o chão seja um objeto estático (imutável pela gravidade ou batidas)
        ground.physicsBody?.isDynamic = false
        // Identifica este nó como "Chão"
        ground.physicsBody?.categoryBitMask = groundCategory

        addChild(ground)
    }

    private func setupCeiling() {
        let ceiling = SKNode()
        ceiling.position = CGPoint(x: self.frame.midX, y: self.frame.maxY)
        ceiling.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        ceiling.physicsBody?.isDynamic = false

        // O teto não tem categoryBitMask customizado porque não precisamos monitorar batidas nele.
        addChild(ceiling)
    }

    private func setupPlayer() {
        player = SKShapeNode(circleOfRadius: 20)
        player.fillColor = .red
        player.strokeColor = .clear
        player.position = CGPoint(x: self.frame.midX, y: self.frame.midY)

        player.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        player.physicsBody?.isDynamic = true
        // Evita que a bolinha saia rolando pelo cenário ao cair
        player.physicsBody?.allowsRotation = false
        // restitution = 0.0 remove o "quique" da bola ao bater no chão
        player.physicsBody?.restitution = 0.0

        // Define quem ele é
        player.physicsBody?.categoryBitMask = playerCategory
        // Define sobre qual batida queremos ser notificados via código (neste caso, se bater no chão)
        player.physicsBody?.contactTestBitMask = groundCategory

        // UI Acoplada: Adicionar elementos como filhos faz com que sigam o pai automaticamente
        jetpack = SKShapeNode(rectOf: CGSize(width: 14, height: 18))
        jetpack.fillColor = .gray
        jetpack.strokeColor = .clear
        jetpack.position = CGPoint(x: 0, y: -20)
        player.addChild(jetpack)

        fuelBar = SKShapeNode(rectOf: CGSize(width: 40, height: 6))
        fuelBar.fillColor = .green
        fuelBar.strokeColor = .clear
        fuelBar.position = CGPoint(x: 0, y: 30)
        player.addChild(fuelBar)

        addChild(player)
    }

    // Input do usuário
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Validação de recurso antes de executar a ação
        if currentFuel >= ignitionCost {
            isTouching = true
            currentFuel -= ignitionCost

            // Zerar a velocidade em Y antes de aplicar o impulso garante um pulo consistente,
            // independente da velocidade em que ele estava caindo.
            player.physicsBody?.velocity.dy = 0
            player.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: jumpImpulse))
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouching = false
    }

    // Chamado se o iOS interromper o toque (ex: notificação cobrindo a tela)
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouching = false
    }

    // Game Loop: Roda antes de cada frame (cerca de 60 vezes por segundo)
    override func update(_ currentTime: TimeInterval) {

        // Verifica o estado continuamente. Se tiver combustível e o dedo estiver na tela:
        if isTouching && currentFuel > 0 {
            // Empurra o personagem para cima
            player.physicsBody?.applyForce(CGVector(dx: 0.0, dy: hoverForce))
            currentFuel -= fuelConsumptionRate

            spawnLiquidParticle()

            // Trava de segurança para não ter combustível negativo
            if currentFuel < 0 {
                currentFuel = 0
                isTouching = false
            }
        }

        updateFuelBarVisuals()
    }

    private func updateFuelBarVisuals() {
        // Regra de três simples para manter o valor entre 0.0 e 1.0
        let fuelRatio = max(currentFuel / maxFuel, 0.0)

        // xScale encolhe a barra visualmente
        fuelBar.xScale = fuelRatio

        // Muda para vermelho se estiver no fim
        fuelBar.fillColor = fuelRatio > 0.3 ? .green : .red
    }

    private func spawnLiquidParticle() {
        let dropRadius = CGFloat.random(in: 3...6)
        let drop = SKShapeNode(circleOfRadius: dropRadius)
        drop.fillColor = UIColor(red: 1.0, green: 0.96, blue: 0.85, alpha: 1.0)
        drop.strokeColor = .clear

        // Como o jetpack é filho do player, sua posição é relativa ao player (0, -20).
        // convert() traduz essa posição para as coordenadas globais da tela para spawnar a gota no lugar certo.
        let spawnPosition = self.convert(jetpack.position, from: player)
        drop.position = spawnPosition

        drop.physicsBody = SKPhysicsBody(circleOfRadius: dropRadius)
        drop.physicsBody?.isDynamic = true

        drop.physicsBody?.categoryBitMask = particleCategory

        // collisionBitMask diz com quem o objeto tem colisão física "dura" (não atravessa).
        drop.physicsBody?.collisionBitMask = groundCategory

        // contactTestBitMask pede ao motor para disparar a função didBegin se bater no chão.
        drop.physicsBody?.contactTestBitMask = groundCategory

        addChild(drop)

        // Limpeza de Memória: Anima a gota sumindo e DESTRÓI o nó para evitar Memory Leak.
        let shrink = SKAction.scale(to: 0.1, duration: 0.6)
        let fade = SKAction.fadeOut(withDuration: 0.6)
        let group = SKAction.group([shrink, fade])
        let remove = SKAction.removeFromParent()

        drop.run(SKAction.sequence([group, remove]))
    }

    // Função engatilhada sempre que dois physics bodies que nós registramos colidem
    func didBegin(_ contact: SKPhysicsContact) {
        // Combinamos os bitmasks colididos usando OR (|) para facilitar a validação
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        // Evento 1: Player tocou o chão. Ação: Resetar recurso.
        if collision == (playerCategory | groundCategory) {
            currentFuel = maxFuel
        }

        // Evento 2: Partícula tocou o chão. Ação: Destruir partícula.
        if collision == (particleCategory | groundCategory) {

            // Como não sabemos se a partícula é o bodyA ou bodyB da batida, verificamos.
            let particleNode = contact.bodyA.categoryBitMask == particleCategory ? contact.bodyA.node : contact.bodyB.node

            // Remove a partícula antes que a animação de encolher (que criamos no spawn) termine sozinha
            particleNode?.removeFromParent()
        }
    }
}
