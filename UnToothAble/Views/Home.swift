//
//  Home.swift
//  UnToothAble
//
//  Created by Antonio Costa on 13/03/26.
//

import SwiftUI

struct Home: View {
    @Environment(GameManager.self) var gameManager
    @AppStorage("hasSeenTutorial") private var hasSeenTutorial = false
    @State private var showTutorial = false
    
    var body: some View {
        
        ZStack{
            VStack {
                HStack{
                    
                    Spacer()
                    
                    
                    CustomIcon(state: .normal, icon: .settings) {
                        gameManager.goToScene(.settings)
                    }
                    
                    CustomIcon(state: .normal, icon: .person) {
                        GameCenterManager.shared.showLeaderboard()
                    }
                    
                                    
                    .onAppear {
                        GameCenterManager.shared.authenticate()
                    }
                    
                }
                .padding(.trailing, 32)
                .padding(.top, 32)
                
                Spacer()
            }
            VStack{
                
                
                
                Image(.logo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 200)
                
                VStack(spacing: 16){
                    
                    CustomButton(label: "PLAY", state: .normal, icon: .play) {
                        gameManager.goToScene(.game)
                    }
                    
                    CustomButton(label: "Shop", state: .normal, icon: .tooth) {
                        gameManager.goToScene(.shop)
                    }
                }
            }
        }
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image(.store)
                .resizable()
                .scaledToFill()
        )
        .ignoresSafeArea()
        .onAppear {
            GameCenterManager.shared.authenticate()
            if !hasSeenTutorial {
                showTutorial = true
            }
        }
        .fullScreenCover(isPresented: $showTutorial) {
            Tutorial(fromSettings: false) {
                hasSeenTutorial = true
                showTutorial = false
                gameManager.goToScene(.game)
            } onDismiss: {
                hasSeenTutorial = true
                showTutorial = false
            }
        }
        
    }
    
}

#Preview {
    Home()
        .environment(GameManager())
}
