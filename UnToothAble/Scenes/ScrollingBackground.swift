import SpriteKit

final class ScrollingBackground: SKNode {
    
    private var backgroundNodes: [SKSpriteNode] = []
    private var backgroundRecycleCount = 0
    private let speedMultiplier: CGFloat = 0.5
    var initialBGs = ["Background1Level1", "Background2Level1", "Background3Level1"]
    
    func setup(in size: CGSize) {
        self.removeAllChildren()
        backgroundNodes.removeAll()
        backgroundRecycleCount = 0
        
        // 1. Criamos um "cursor" para saber exatamente onde a última imagem terminou
        var currentX: CGFloat = 0
        
//        for setIndex in 0..<2 {
            for (imageIndex, name) in initialBGs.enumerated() {
                let bg = SKSpriteNode(imageNamed: name)
                
                let aspectRatio = bg.texture!.size().width / bg.texture!.size().height
                let scaleHeight = size.height
                let scaleWidth = scaleHeight * aspectRatio
                bg.size = CGSize(width: scaleWidth, height: scaleHeight)
                
                // 2. Posicionamos o centro da imagem baseando-se no currentX
                // Como o anchorPoint padrão é (0.5, 0.5), o X precisa estar na metade da largura
                bg.position = CGPoint(x: currentX + (scaleWidth / 2), y: size.height / 2)
                
                bg.zPosition = -10
                bg.name = "bg_\(imageIndex)"
                
                addChild(bg)
                backgroundNodes.append(bg)
                
                // 3. Atualizamos o cursor para o final desta imagem.
                // O "- 1" é o segredo: ele faz a próxima imagem sobrepor 1 pixel, eliminando as linhas em branco!
                currentX += scaleWidth - 1
            }
//        }
    }
    
    func update(deltaTime: TimeInterval, scenarioSpeed: CGFloat) {
        let moveX = scenarioSpeed * CGFloat(deltaTime) * speedMultiplier
        
        // Movemos todas as imagens primeiro
        for bg in backgroundNodes {
            bg.position.x -= moveX
        }
        
        // Depois verificamos a reciclagem
        for bg in backgroundNodes {
            // Verifica se a Borda Direita da imagem passou do limite esquerdo da tela (X = 0)
            if bg.position.x + (bg.size.width / 2) < 0 {
                
                // 4. Encontra a imagem que está mais à direita no momento
                if let rightMostNode = backgroundNodes.max(by: { $0.position.x < $1.position.x }) {
                    
                    // 5. Gruda a imagem reciclada perfeitamente na borda direita da última imagem (com a sobreposição de 1 pixel)
                    let newX = rightMostNode.position.x + (rightMostNode.size.width / 2) + (bg.size.width / 2) - 1
                    bg.position.x = newX
                    
                    backgroundRecycleCount += 1
                    print(backgroundRecycleCount)
                    print(initialBGs)
                    
                    // Troca de fase
                    if backgroundRecycleCount == 6 {
                        if bg.name == "bg_0" {
                            initialBGs[0] = "Background1To2"
//                            bg.texture = SKTexture(imageNamed: "Background1To2")
                        } else if bg.name == "bg_1" {
                            initialBGs[1] = "ackgroundTransitionTo2"
//                            bg.texture = SKTexture(imageNamed: "BackgroundTransitionTo2")
                        } else if bg.name == "bg_2" {
                            initialBGs[2] = "Background3Level2"

//                            bg.texture = SKTexture(imageNamed: "Background3Level2")
                        }
                    }
                    if backgroundRecycleCount == 8 {
                        if bg.name == "bg_0" {
                            bg.texture = SKTexture(imageNamed: "Background1Level2")
                        } else if bg.name == "bg_1" {
                            bg.texture = SKTexture(imageNamed: "Background2Level2")
                        }
                    }
                }
            }
        }
    }
    
    func reset(in size: CGSize) {
        setup(in: size)
    }
}
