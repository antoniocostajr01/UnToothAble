//
//  EnemyScene.swift
//  POC_Inimigo_voador
//
//  Created by Richard Fagundes Rodrigues on 12/03/26.
//

import SpriteKit

class EnemyScene: SKScene {
    
    private var enemy: SKShapeNode!
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .black
        
        // Remove a gravidade global da cena, já que tudo nesta POC voa/flutua
        self.physicsWorld.gravity = .zero
        
        setupEnemy()
        startObstacleSpawner()
    }
    
    // MARK: - Inimigo e Movimentação
    private func setupEnemy() {
        enemy = SKShapeNode(circleOfRadius: 25)
        enemy.fillColor = .green
        enemy.strokeColor = .clear
        
        // Agora ele nasce FORA da tela, na direita
        enemy.position = CGPoint(x: self.frame.maxX + 100, y: self.frame.midY)
        addChild(enemy)
        
        // 1. O flutuar no eixo Y roda de forma independente e contínua
        animateEnemyHover()
        
        // 2. O ciclo de ataque gerencia o eixo X e os tiros
        startEnemyCycle()
    }
    
    private func animateEnemyHover() {
        // Criação do movimento de "sobe e desce" usando SKAction
        // O timingMode .easeInEaseOut desacelera o movimento nas pontas, criando o efeito suave de flutuação
        let moveUp = SKAction.moveBy(x: 0, y: 80, duration: 1.2)
        moveUp.timingMode = .easeInEaseOut
        
        let moveDown = moveUp.reversed()
        moveDown.timingMode = .easeInEaseOut
        
        let hoverSequence = SKAction.sequence([moveUp, moveDown])
        enemy.run(SKAction.repeatForever(hoverSequence))
    }
    
    private func startEnemyCycle() {
        // Coordenadas de controle
        let offScreenX = self.frame.maxX + 100
        let inScreenX = self.frame.maxX - 50
        
        // 1. Entrar na tela
        let moveIn = SKAction.moveTo(x: inScreenX, duration: 1.0)
        moveIn.timingMode = .easeOut // Desacelera ao chegar
        
        // 2. Fase de Ataque (Atira 3 vezes com intervalo de 1 segundo)
        let waitToShoot = SKAction.wait(forDuration: 1.0)
        let shoot = SKAction.run { [weak self] in
            self?.spawnProjectile()
        }
        let attackRoutine = SKAction.sequence([waitToShoot, shoot])
        let attackPhase = SKAction.repeat(attackRoutine, count: 3)
        
        // 3. Sair da tela (Pausa breve, depois recua)
        let waitBeforeLeave = SKAction.wait(forDuration: 0.5)
        let moveOut = SKAction.moveTo(x: offScreenX, duration: 1.0)
        moveOut.timingMode = .easeIn // Acelera ao fugir
        
        // 4. Cooldown (Tempo que o inimigo fica sumido antes de voltar)
        let cooldown = SKAction.wait(forDuration: 4.0)
        
        // Concatena tudo e repete para sempre
        let fullCycle = SKAction.sequence([moveIn, attackPhase, waitBeforeLeave, moveOut, cooldown])
        enemy.run(SKAction.repeatForever(fullCycle))
    }
    
    private func spawnProjectile() {
        let projectile = SKShapeNode(circleOfRadius: 8)
        projectile.fillColor = .green
        projectile.strokeColor = .clear
        
        // O tiro nasce exatamente na posição atual do inimigo
        projectile.position = enemy.position
        
        addChild(projectile)
        
        // Move o tiro para a esquerda até sair da tela e depois destrói o nó
        let moveLeft = SKAction.moveBy(x: -self.frame.width - 100, y: 0, duration: 2.0)
        let remove = SKAction.removeFromParent()
        
        projectile.run(SKAction.sequence([moveLeft, remove]))
    }
    
    // MARK: - Sistema de Objetos "Estáticos" (Obstáculos)
    private func startObstacleSpawner() {
        // Spawna um objeto a cada 3.5 segundos
        let wait = SKAction.wait(forDuration: 3.5)
        let spawn = SKAction.run { [weak self] in
            self?.spawnStaticObject()
        }
        
        let spawnSequence = SKAction.sequence([wait, spawn])
        self.run(SKAction.repeatForever(spawnSequence))
    }
    
    private func spawnStaticObject() {
        // Objeto em baixa fidelidade (um quadrado cinza)
        let obstacle = SKShapeNode(rectOf: CGSize(width: 40, height: 40))
        obstacle.fillColor = .gray
        obstacle.strokeColor = .clear
        
        // Define uma altura aleatória para o objeto nascer, mantendo uma margem segura das bordas
        let randomY = CGFloat.random(in: (self.frame.minY + 50)...(self.frame.maxY - 50))
        
        // Nasce fora da tela, na direita
        obstacle.position = CGPoint(x: self.frame.maxX + 50, y: randomY)
        
        addChild(obstacle)
        
        // Simula a "corrida do jogo" movendo o objeto para a esquerda em velocidade constante
        // A duração define a velocidade da corrida (menor = mais rápido)
        let moveLeft = SKAction.moveTo(x: self.frame.minX - 50, duration: 4.0)
        let remove = SKAction.removeFromParent()
        
        obstacle.run(SKAction.sequence([moveLeft, remove]))
    }
}
