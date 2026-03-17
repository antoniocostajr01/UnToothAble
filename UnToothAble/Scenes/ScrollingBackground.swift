//
//  BackgroundMoving.swift
//  UnToothAble
//
//  Substituição direta. Não é necessário alterar a GameScene.swift!
//

import SpriteKit

final class ScrollingBackground: SKNode {
    
    private var backgroundNodes: [SKSpriteNode] = []
    private var totalRecycles = 0
    
    // Parallax: 0.5 faz o fundo mover na metade da velocidade do chão
    private let speedMultiplier: CGFloat = 0.5
    
    private let initialBGs = ["Background1Level1", "Background2Level1", "Background3Level1"]
    
    // Guardamos a largura padrão para garantir que todas as partes tenham o mesmo tamanho
    private var panelWidth: CGFloat = 0
    
    func setup(in size: CGSize) {
        // Limpa caso esteja reiniciando (Game Over)
        self.removeAllChildren()
        backgroundNodes.removeAll()
        totalRecycles = 0
        
        // 1. Pega a proporção da PRIMEIRA imagem para ditar a regra
        let sampleTexture = SKTexture(imageNamed: initialBGs[0])
        let aspectRatio = sampleTexture.size().width / sampleTexture.size().height
        
        // Calcula a largura que a imagem deve ter para preencher a altura da tela
        panelWidth = size.height * aspectRatio
        
        // 2. Cria APENAS 3 painéis (é o suficiente para cobrir a tela e fazer o loop)
        for (index, name) in initialBGs.enumerated() {
            let bg = SKSpriteNode(imageNamed: name)
            
            // Força todos a terem o mesmo tamanho exato
            bg.size = CGSize(width: panelWidth, height: size.height)
            
            // Posiciona um perfeitamente ao lado do outro
            let startX = (panelWidth / 2) + (panelWidth * CGFloat(index))
            bg.position = CGPoint(x: startX, y: size.height / 2)
            
            bg.zPosition = -10 // Fundo atrás de tudo
            bg.name = "bg_\(index)" // Identificador para a troca de textura
            
            addChild(bg)
            backgroundNodes.append(bg)
        }
    }
    
    // Método que a sua GameScene já chama automaticamente
    // Método que a sua GameScene já chama automaticamente
        func update(deltaTime: TimeInterval, scenarioSpeed: CGFloat) {
            let moveX = scenarioSpeed * CGFloat(deltaTime) * speedMultiplier
            
            for bg in backgroundNodes {
                // 1. Move a imagem
                bg.position.x -= moveX
                
                // 2. Verifica se saiu TOTALMENTE da tela pela esquerda
                if bg.position.x <= -(panelWidth / 2) {
                    
                    // Joga a imagem para o final da fila exata (3 larguras de distância)
                    bg.position.x += panelWidth * 3
                    
                    totalRecycles += 1
                    
                    // 3. Troca de textura DEBAIXO DOS PANOS - Painel por Painel
                    if bg.name == "bg_0" {
                        if totalRecycles == 7 {
                            // Terceira vez que o bg_0 recicla: Vira Transição
                            bg.texture = SKTexture(imageNamed: "TransitionBG1")
                        } else if totalRecycles >= 10 {
                            // Quarta vez em diante: Vira Level 2 definitivo
                            bg.texture = SKTexture(imageNamed: "Background1Level2")
                        }
                    }
                    else if bg.name == "bg_1" {
                        if totalRecycles == 8 {
                            // Terceira vez que o bg_1 recicla: Vira Transição
                            bg.texture = SKTexture(imageNamed: "TransitionBG2")
                        } else if totalRecycles >= 11 {
                            // Quarta vez em diante: Vira Level 2 definitivo
                            bg.texture = SKTexture(imageNamed: "Background2Level2")
                        }
                    }
                    else if bg.name == "bg_2" {
                        // O bg_2 não tem uma textura de "transição", ele já assume o level 2 e fica.
                        // A partir da reciclagem 9, ele sempre será o Level 2.
                        if totalRecycles >= 9 {
                            bg.texture = SKTexture(imageNamed: "Background3Level2")
                        }
                    }
                }
            }
        }
    
    // Reseta o background para o estado inicial
    func reset(in size: CGSize) {
        setup(in: size)
    }
}
