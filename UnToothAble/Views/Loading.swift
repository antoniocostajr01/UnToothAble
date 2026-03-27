//
//  LoadingView.swift
//  UnToothAble
//
//  Created by Antonio Costa on 24/03/26.
//

//
//  LoadingView.swift
//

import SwiftUI

struct Loading: View {
    
    @Environment(GameManager.self) var gameManager
    @State private var isLoading = true
    @State private var currentFrameIndex: Int = 0
    @State private var animationTask: Task<Void, Never>? = nil
    private let frames: [ImageResource] = [.tooth1, .tooth2, .tooth3, .tooth4, .tooth5]
    
    
    var body: some View {
        ZStack {
            Image(.store)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                Image(frames[currentFrameIndex])
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                
                
                LoadingView()
                
//                ProgressView()
//                    .scaleEffect(2.5)
//                    .padding(.top, 24)
            }
        }
        .onAppear {
            animationTask = Task { @MainActor in
                while isLoading {
                    try? await Task.sleep(for: .seconds(0.08))
                    guard isLoading else { break }
                    currentFrameIndex = (currentFrameIndex + 1) % frames.count
                }
            }
            
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 4_000_000_000)
                isLoading = false
                animationTask?.cancel()
                gameManager.goToScene(.game)
            }
        }
        .onDisappear {
            animationTask?.cancel()
        }
        
    }
}


#Preview {
    Loading()
        .environment(GameManager())
}

