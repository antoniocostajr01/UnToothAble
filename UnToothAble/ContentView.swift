//
//  ContentView.swift
//  UnToothAble
//
//  Created by Antonio Costa on 13/03/26.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    private let scene: GameScene = {
        let scene = GameScene()
        scene.scaleMode = .resizeFill
        return scene
    }()
    
    var body: some View {
        ZStack{
            BackgroundMoving()
            
            SpriteView(scene: scene)
                .ignoresSafeArea()
                .onAppear {
                    GameCenterManager.shared.authenticate()
                }
            
        }
    }
}

#Preview {
    ContentView()
}
