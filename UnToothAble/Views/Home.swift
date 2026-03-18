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
        
            VStack(spacing: 32) {
                Text("UnToothAble")
                    .foregroundStyle(.red)
                    .font(.system(size: 60))

                Button {
                    gameManager.goToScene(.game)
                } label: {
                    Text("Play")
                        .foregroundStyle(.black)
                        .font(.system(size: 60))
                }
                
                Button {
                    gameManager.goToScene(.shop)
                } label: {
                    Text("Shop")
                        .foregroundStyle(.black)
                        .font(.system(size: 60))
                }
            }
            .padding()
            .background(.white)
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
        
        Button {
            gameManager.goToScene(.settings)
        } label: {
            Image(systemName: "gear")
                .foregroundStyle(.white)
                .font(.system(size: 40))
        }
        .padding(.leading, 720)
        .padding(.trailing, 16)
        
        
        Button {
            GameCenterManager.shared.showLeaderboard()
        } label: {
            Image(systemName: "gamecontroller.fill")
                .foregroundStyle(.white)
                .font(.system(size: 40))
        }
        .padding(.leading, 754)
        .padding(.trailing, 16)
        .padding(.bottom, 327)
        
        .onAppear {
               GameCenterManager.shared.authenticate()
           }
    }
        
}

#Preview {
    Home()
        .environment(GameManager())
}
