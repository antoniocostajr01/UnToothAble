//
//  BackgroundMoving.swift
//  UnToothAble
//
//  Estrutura escalável para 4 níveis (Level 1, Level 2, Rua e Esgoto)
//

import SpriteKit

final class ScrollingBackground: SKNode {
    
    private var backgroundNodes: [SKSpriteNode] = []
    private var totalRecycles = 0
    
    // Parallax: 0.5 faz o fundo mover na metade da velocidade do chão
    private let speedMultiplier: CGFloat = 0.5
    
    var onLevelUp: (() -> Void)?
    
    private let initialBGs = ["Background1Level1", "Background2Level1", "Background3Level1"]
    
    // Guardamos a largura padrão para garantir que todas as partes tenham o mesmo tamanho
    private var panelWidth: CGFloat = 0
    
    func setup(in size: CGSize) {
        self.removeAllChildren()
        backgroundNodes.removeAll()
        totalRecycles = 0
        
        let sampleTexture = SKTexture(imageNamed: initialBGs[0])
        let aspectRatio = sampleTexture.size().width / sampleTexture.size().height
        
        panelWidth = size.height * aspectRatio
        
        for (index, name) in initialBGs.enumerated() {
            let bg = SKSpriteNode(imageNamed: name)
            bg.size = CGSize(width: panelWidth, height: size.height)
            
            let startX = (panelWidth / 2) + (panelWidth * CGFloat(index))
            bg.position = CGPoint(x: startX, y: size.height / 2)
            
            bg.zPosition = -10
            bg.name = "bg_\(index)"
            
            addChild(bg)
            backgroundNodes.append(bg)
        }
    }
    
    func update(deltaTime: TimeInterval, scenarioSpeed: CGFloat) {
        let moveX = scenarioSpeed * CGFloat(deltaTime) * speedMultiplier
        
        for bg in backgroundNodes {
            bg.position.x -= moveX
            
            if bg.position.x <= -(panelWidth / 2) {
                bg.position.x += panelWidth * 3
                totalRecycles += 1
                print(totalRecycles)
                
                // 3. Troca de textura escalável usando Switch
                if bg.name == "bg_0" {
                    switch totalRecycles {
                        // Transição L1 -> L2
                    case 1:
                        bg.texture = SKTexture(imageNamed: "Background1Level2")
                        
                    case 4:
                        bg.texture = SKTexture(imageNamed: "Background1Level3")
                        onLevelUp?() // <--- AVISA QUE O LEVEL 2 COMEÇOU!
                    
                    case 7:
                        bg.texture = SKTexture(imageNamed: "Background1Level4")
                        onLevelUp?() // <--- AVISA QUE O LEVEL 2 COMEÇOU!
                        
                        // Transição L2 -> L3 (Rua)
               
                    default: break
                    }
                }
                else if bg.name == "bg_1" {
                    switch totalRecycles {
                        // Transição L1 -> L2
                    case 2:  bg.texture = SKTexture(imageNamed: "Background2Level2")
                        
                    case 5:  bg.texture = SKTexture(imageNamed: "Background2Level3")
                        
                    case 8:  bg.texture = SKTexture(imageNamed: "Background2Level4")
                    
                        
                    default: break
                    }
                }
                else if bg.name == "bg_2" {
                    switch totalRecycles {
                        // Finais dos blocos (O bg_2 não usa transição, ele já entra definitivo)
                    case 3:  bg.texture = SKTexture(imageNamed: "Background3Level2")
                    case 6:  bg.texture = SKTexture(imageNamed: "Background3Level3")
                    case 9:  bg.texture = SKTexture(imageNamed: "Background3Level4")
                    
                        
                    default: break
                    }
                }
            }
        }
    }
    
    func reset(in size: CGSize) {
        setup(in: size)
    }
}
