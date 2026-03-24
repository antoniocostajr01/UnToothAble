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
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                Text("Loading...")
                    .font(.headline)
                    .foregroundStyle(.black)
            }
        }
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                gameManager.goToScene(.game)
            }
        }
        
    }
}

#Preview {
    Loading()
}
