//
//  BackgroundMoving.swift
//  UnToothAble
//
//  Created by Antonio Costa on 13/03/26.
//

import SwiftUI
internal import Combine

struct BackgroundMoving: View {
    
    @State private var isWalking = false
    @State private var backgroundOffset: CGFloat = 0
    
    // Nomes das imagens
    @State private var bg1Name = "Background1"
    @State private var bg2Name = "Background2"
    @State private var bg3Name = "Background3"
    
    // Controle de tempo dinâmico
    @State private var timeElapsed: Double = 0.0
    // Timer mais rápido (0.1s) para precisão milimétrica, independente da velocidade
    let loopTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    let animationDuration: Double = 0.5
    // Você pode mudar isso para qualquer valor no futuro, a lógica não vai quebrar!
    let backgroundSpeed: Double = 3
    
    var body: some View {
        
        GeometryReader { geometry in
            
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            ZStack {
                // CENÁRIO
                HStack(spacing: 0) {
                
                    // BLOCO ORIGINAL
                    Group {
                        Image(bg1Name).resizable().aspectRatio(contentMode: .fill)
                            .frame(width: screenWidth, height: screenHeight).clipped()
                        Image(bg2Name).resizable().aspectRatio(contentMode: .fill)
                            .frame(width: screenWidth, height: screenHeight).clipped()
                        Image(bg3Name).resizable().aspectRatio(contentMode: .fill)
                            .frame(width: screenWidth, height: screenHeight).clipped()
                    }
                    
                    // BLOCO CÓPIA
                    Group {
                        Image(bg1Name).resizable().aspectRatio(contentMode: .fill)
                            .frame(width: screenWidth, height: screenHeight).clipped()
                        Image(bg2Name).resizable().aspectRatio(contentMode: .fill)
                            .frame(width: screenWidth, height: screenHeight).clipped()
                        Image(bg3Name).resizable().aspectRatio(contentMode: .fill)
                            .frame(width: screenWidth, height: screenHeight).clipped()
                    }
                }
                .frame(width: screenWidth * 6, alignment: .leading)
                .offset(x: backgroundOffset)
                .onAppear {
                    backgroundOffset = 0
                    withAnimation(.linear(duration: backgroundSpeed).repeatForever(autoreverses: false)) {
                        backgroundOffset = -(screenWidth * 3)
                    }
                }
                
                // PERSONAGEM
                VStack {
                    Spacer()
                    
                    HStack {
                        Image(.teeth)
                            .resizable()
                            .frame(width: 203, height: 200)
                            .offset(y: isWalking ? -10 : 0)
                            .padding(.leading, 30)
                        
                        Spacer()
                    }
                    .padding(.bottom, 50)
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: animationDuration).repeatForever(autoreverses: true)) {
                        isWalking = true
                    }
                }
            }
        }
        .ignoresSafeArea()
        
        // MÁGICA DOS CICLOS DINÂMICOS
        .onReceive(loopTimer) { _ in
            timeElapsed += 0.1
            
            // 1. Descobre em qual ciclo estamos (0 = primeiro, 1 = segundo, 2 = terceiro)
            let currentCycle = Int(timeElapsed / backgroundSpeed)
            
            // 2. Descobre a porcentagem do ciclo atual (de 0.0 a 1.0)
            let cycleFraction = (timeElapsed.truncatingRemainder(dividingBy: backgroundSpeed)) / backgroundSpeed
            
            // Queremos trocar durante o 3º ciclo (currentCycle == 2)
            if currentCycle == 2 {
                
                // Se passou de 40% do ciclo, a Imagem 1 já saiu da tela com segurança. Pode trocar.
                if cycleFraction > 0.4 && bg1Name == "Background1" {
                    bg1Name = "BackgroundNaruto"
                }
                
                // Se passou de 75% do ciclo, a Imagem 2 já saiu da tela com segurança. Pode trocar.
                if cycleFraction > 0.75 && bg2Name == "Background2" {
                    bg2Name = "BackgroundNaruto2"
                    
                    // As duas imagens já foram trocadas, podemos desligar o timer!
                    loopTimer.upstream.connect().cancel()
                }
            }
        }
    }
}

#Preview {
    BackgroundMoving()
}
