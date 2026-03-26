//
//  BackgroundMoving.swift
//  UnToothAble
//
//

import SpriteKit

final class ScrollingBackground: SKNode {
    
    private var backgroundNodes: [SKSpriteNode] = []
    private var totalRecycles = 0
    
    // Parallax: 0.5 faz o fundo mover na metade da velocidade do chão
    private let speedMultiplier: CGFloat = 0.25

    var onLevelUp: (() -> Void)?
    /// Disparado uma vez quando totalRecycles chega a 4 (transição Scene5→6)
    var onBossUnlocked: (() -> Void)?
    
    private let initialBGs = [
        "Scene1", "Scene2", "Scene3", "Scene4", "Scene5"
    ]
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
                bg.position.x += panelWidth * CGFloat(backgroundNodes.count)
                totalRecycles += 1
            
                switch totalRecycles{
                case 4:
                    onLevelUp?()
                    onBossUnlocked?()

                default:
                    break
                }
                
                            
                // 3. Troca de textura escalável usando Switch
                if bg.name == "bg_0" {
                    switch totalRecycles {
                    case 1: bg.texture = SKTexture(imageNamed: "Scene6")
                    case 6: bg.texture = SKTexture(image: .scene11) // 2ª vez que o bg_0 dá a volta
                    default: break
                    }
                }
                else if bg.name == "bg_1" {
                    switch totalRecycles {
                    case 2: bg.texture = SKTexture(image: .scene7)
                    default: break
                    }
                }
                else if bg.name == "bg_2" {
                    switch totalRecycles {
                    case 3: bg.texture = SKTexture(image: .scene8)
                    default: break
                    }
                }
                else if bg.name == "bg_3" {
                    switch totalRecycles {
                    case 4: bg.texture = SKTexture(image: .scene9)
                    default: break
                    }
                }
                else if bg.name == "bg_4" {
                    switch totalRecycles {
                    case 5: bg.texture = SKTexture(image: .scene10)
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
