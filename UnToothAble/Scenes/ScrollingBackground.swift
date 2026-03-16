//
//  BackgroundMoving.swift
//  UnToothAble
//
//  Created by Antonio Costa on 13/03/26.
//

import SpriteKit

final class ScrollingBackground: SKNode {
    
    private var backgroundNodes: [SKSpriteNode] = []
    private var backgroundRecycleCount = 0
    
    // Parallax: 0.5 faz o fundo mover na metade da velocidade do chão, dando efeito de profundidade.
    // Se quiser a mesma velocidade, mude para 1.0
    private let speedMultiplier: CGFloat = 0.5
    
    // Configuração das imagens da primeira fase
    private let initialBGs = ["Background1", "Background2", "Background3"]
    
    func setup(in size: CGSize) {
        // Limpa caso esteja reiniciando
        self.removeAllChildren()
        backgroundNodes.removeAll()
        backgroundRecycleCount = 0
        
        // Cria 2 blocos (o original e a cópia para o loop)
        for setIndex in 0..<2 {
            for (imageIndex, name) in initialBGs.enumerated() {
                let bg = SKSpriteNode(imageNamed: name)
                
                // Calcula a escala para preencher a tela (Aspect Fill)
                let aspectRatio = bg.texture!.size().width / bg.texture!.size().height
                let scaleHeight = size.height
                let scaleWidth = scaleHeight * aspectRatio
                bg.size = CGSize(width: scaleWidth, height: scaleHeight)
                
                // Posiciona um ao lado do outro
                let positionIndex = CGFloat(imageIndex + (setIndex * initialBGs.count))
                bg.position = CGPoint(x: (scaleWidth / 2) + (scaleWidth * positionIndex), y: size.height / 2)
                
                bg.zPosition = -10 // Joga o fundo para trás de tudo
                bg.name = "bg_\(imageIndex)" // Etiqueta (0, 1 ou 2) para identificar na hora de trocar
                
                addChild(bg)
                backgroundNodes.append(bg)
            }
        }
    }
    
    // Método que a GameScene vai chamar a cada frame
    func update(deltaTime: TimeInterval, scenarioSpeed: CGFloat) {
        let moveX = scenarioSpeed * CGFloat(deltaTime) * speedMultiplier
        
        for bg in backgroundNodes {
            // 1. Move a imagem
            bg.position.x -= moveX
            
            // 2. Verifica se saiu da tela (Reciclagem)
            if bg.position.x < -(bg.size.width / 2) {
                // Joga a imagem para o final da fila (à direita)
                let rightMostX = backgroundNodes.map(\.position.x).max() ?? 0
                bg.position.x = rightMostX + bg.size.width
                
                backgroundRecycleCount += 1
                
                // 3. Regra de troca de texturas (A mágica "por baixo dos panos")
                // Após 2 ciclos completos (aprox. 12 reciclagens), começa a trocar
                if backgroundRecycleCount > 2 {
                    if bg.name == "bg_0" {
                        bg.texture = SKTexture(imageNamed: "BackgroundNaruto")
                    } else if bg.name == "bg_1" {
                        bg.texture = SKTexture(imageNamed: "BackgroundNaruto2")
                    }
                    // Você pode adicionar mais condições para o bg_2 ou outras fases aqui
                }
            }
        }
    }
    
    // Reseta o background para o estado inicial (útil para o Game Over)
    func reset(in size: CGSize) {
        setup(in: size)
    }
}
