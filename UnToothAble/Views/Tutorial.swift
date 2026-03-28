//
//  Tutorial.swift
//  UnToothAble
//
//  Created by sofia leitao on 17/03/26.
//
//
//  Tutorial.swift
//  UnToothAble
//
//  Created by sofia leitao on 17/03/26.
//
import SwiftUI

struct Tutorial: View {
    
    @State private var step1Opacity = 0.0
    @State private var step2Opacity = 0.0
    @State private var step3Opacity = 0.0
    @State private var isShowingButton = false
    @Environment(GameManager.self) var gameManager
    
    let fromSettings: Bool
    let onSkip: () -> Void
    let onDismiss: (() -> Void)? //so usado quando vem de settings
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                Text("Tutorial")
                    .font(.bangers(54))
                    .foregroundStyle(.white)
                    .padding(.top, 24)
                
                HStack(alignment: .top ,spacing: 16) {
                    //MARK: - Primeira coluna do tutorial
                    AnimatedToothColumn(isActive: step1Opacity == 1.0)
                        .opacity(step1Opacity)
                    
                    //MARK: - Segunda coluna do tutorial
                    AnimatedEnemiesColumn(isActive: step2Opacity == 1.0)
                        .opacity(step2Opacity)
                    
                    //MARK: - Terceira coluna do tutorial
                    AnimatedFuelColumn(isActive: step3Opacity == 1.0)
                        .opacity(step3Opacity)
                }
                .padding(.horizontal, 32) // Afasta as colunas das bordas da tela
                .frame(height: 200)
                
                HStack {
                    Spacer()
                    CustomButton(label: "Got it!", state: .normal) {
                        if fromSettings {
                            onDismiss?()
                        } else {
                            if gameManager.hasSawHistory == false {
                                onDismiss?()
                            } else {
                                onSkip()
                            }
                        }
                    }
                    .padding(.trailing, 40) // Afasta o botão da borda direita
                    .padding(.bottom, 32)   // Afasta o botão da borda inferior
                    .opacity(isShowingButton ? 1.0 : 0.0)
                    .disabled(!isShowingButton)
                }
                .padding(.top, 32)
            }
            
        }
        .onAppear {
            // MARK: - Orquestração (O Gran Finale!)
            Task {
                // 1. Mostra a primeira coluna
                withAnimation(.easeIn(duration: 0.5)) { step1Opacity = 1.0 }
                // Espera a animação rolar um pouco para o jogador assimilar
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                
                // 2. Mostra a segunda coluna e começa a revelar os inimigos
                withAnimation(.easeIn(duration: 0.5)) { step2Opacity = 1.0 }
                // Espera o tempo de todos os inimigos aparecerem (~1.8s) + uma margem
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                
                // 3. Mostra a terceira coluna da barra de combustível
                withAnimation(.easeIn(duration: 0.5)) { step3Opacity = 1.0 }
                // Espera um segundo
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                
                // 4. Finalmente, revela o botão de continuar!
                withAnimation(.easeIn(duration: 0.5)) { isShowingButton = true }
            }
        }
    }
}


struct AnimatedToothColumn: View {
    var isActive: Bool // ✨ Nova propriedade para controlar o inicio
    
    let runningFrames = ["Tooth1", "Tooth2", "Tooth3", "Tooth4", "Tooth5"]
    @State private var currentFrame = "Tooth1"
    
    @State private var isTapping = false
    @State private var isFlying = false
    @State private var animateParticles = false
    
    var body: some View {
        VStack {
            Text("Tap the screen to activate your jetpack and fly up!")
                .foregroundStyle(.white)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .lineLimit(4)
                .minimumScaleFactor(0.8) // Permite encolher a fonte se necessário
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, minHeight: 90)
            
            Spacer()
            
            ZStack {
                // MARK: Efeito de Propulsão (Bolinhas)
                if isFlying {
                    VStack(spacing: 8) {
                        Circle()
                            .fill(.white.opacity(0.8))
                            .frame(width: 8, height: 8)
                            .offset(y: animateParticles ? 40 : 0)
                            .opacity(animateParticles ? 0 : 1)
                            .animation(.easeOut(duration: 0.4).repeatForever(autoreverses: false), value: animateParticles)
                        
                        Circle()
                            .fill(.white.opacity(0.6))
                            .frame(width: 12, height: 12)
                            .offset(y: animateParticles ? 50 : 0)
                            .opacity(animateParticles ? 0 : 1)
                            .animation(.easeOut(duration: 0.5).repeatForever(autoreverses: false).delay(0.1), value: animateParticles)
                        
                        Circle()
                            .fill(.white.opacity(0.8))
                            .frame(width: 8, height: 8)
                            .offset(y: animateParticles ? 40 : 0)
                            .opacity(animateParticles ? 0 : 1)
                            .animation(.easeOut(duration: 0.4).repeatForever(autoreverses: false).delay(0.2), value: animateParticles)
                    }
                    .offset(y: -10)
                }
                
                // MARK: Personagem Principal
                Image(currentFrame)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 65, height: 74)
                    .offset(y: isFlying ? -40 : .zero)
                
                // MARK: Mão Clicando
                Image(systemName: "hand.point.up.left.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(.white)
                    .rotationEffect(.degrees(40))
                    .opacity(0.5)
                    .scaleEffect(isTapping ? 0.85 : 1.0)
                    .offset(x: -70, y: isTapping ? 30 : 50)
            }
        }
        // ✨ O '.task(id:)' garante que a animação só comece quando o isActive virar true
        .task(id: isActive) {
            if isActive {
                await startAnimationSequence()
            }
        }
    }
    
    private func startAnimationSequence() async {
        while !Task.isCancelled {
            isFlying = false
            isTapping = false
            animateParticles = false
            currentFrame = runningFrames[0]
            
            for i in 0..<8 {
                currentFrame = runningFrames[i % runningFrames.count]
                try? await Task.sleep(nanoseconds: 150_000_000)
            }
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isTapping = true
            }
            try? await Task.sleep(nanoseconds: 200_000_000)
            
            currentFrame = "Tooth3"
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isFlying = true
            }
            
            try? await Task.sleep(nanoseconds: 100_000_000)
            animateParticles = true
            
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            
            animateParticles = false
            withAnimation(.easeInOut(duration: 0.6)) {
                isFlying = false
                isTapping = false
            }
            
            try? await Task.sleep(nanoseconds: 600_000_000)
        }
    }
}


struct AnimatedEnemiesColumn: View {
    var isActive: Bool // ✨ Nova propriedade
    
    @State private var opacities: [Double] = [0, 0, 0, 0, 0, 0]
    @State private var scales: [Double] = [0.5, 0.5, 0.5, 0.5, 0.5, 0.5]
    
    var body: some View {
        VStack {
            Text("Watch out for enemies! Dodge them to survive.")
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .lineLimit(4)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, minHeight: 90)
            
            Spacer()
            
            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    enemyImage(.carie1, index: 0)
                    enemyImage(.coke1, index: 1)
                    enemyImage(.fairyFrame1, index: 2)
                }
                
                HStack(spacing: 20) {
                    enemyImage(.pigeon1, index: 3)
                    enemyImage(.roach1, index: 4)
                    enemyImage(.fly1, index: 5)
                }
            }
        }
        // ✨ Inicia a revelação apenas quando fica ativo
        .task(id: isActive) {
            if isActive {
                await startRevealSequence()
            }
        }
    }
    
    @ViewBuilder
    private func enemyImage(_ image: ImageResource, index: Int) -> some View {
        Image(image)
            .resizable()
            .scaledToFill()
            .frame(width: 40, height: 40)
            .opacity(opacities[index])
            .scaleEffect(scales[index])
    }
    
    private func startRevealSequence() async {
        opacities = Array(repeating: 0.0, count: 6)
        scales = Array(repeating: 0.5, count: 6)
        
        for index in 0..<6 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                opacities[index] = 1.0
                scales[index] = 1.0
            }
            try? await Task.sleep(nanoseconds: 300_000_000)
        }
    }
}


struct AnimatedFuelColumn: View {
    var isActive: Bool // ✨ Nova propriedade
    
    let fuelFrames = ["fuelBar1", "fuelBar2", "fuelBar3", "fuelBar4", "fuelBar5"]
    @State private var currentFrame = "fuelBar1"
    
    var body: some View {
        VStack {
            Text("Keep an eye on your fuel! It drains as you fly.")
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .lineLimit(4)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, minHeight: 90)
            
            Spacer()
            
            Image(currentFrame)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 150)
        }
        // ✨ Inicia a barra de combustível apenas quando fica ativo
        .task(id: isActive) {
            if isActive {
                await startFuelAnimation()
            }
        }
    }
    
    private func startFuelAnimation() async {
        while !Task.isCancelled {
            for i in 0..<fuelFrames.count {
                currentFrame = fuelFrames[i]
                try? await Task.sleep(nanoseconds: 300_000_000)
            }
            
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            for i in stride(from: fuelFrames.count - 2, through: 0, by: -1) {
                currentFrame = fuelFrames[i]
                try? await Task.sleep(nanoseconds: 300_000_000)
            }
            
            try? await Task.sleep(nanoseconds: 500_000_000)
        }
    }
}

#Preview {
    Tutorial(
        fromSettings: false,
        onSkip: {
            print("Botão clicado: Pulou o tutorial inicial!")
        },
        onDismiss: nil
    )
    .environment(GameManager())
}
