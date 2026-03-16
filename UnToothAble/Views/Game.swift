//
//  Game.swift
//  UnToothAble
//
//  Created by Antonio Costa on 15/03/26.
//
import SpriteKit
import SwiftUI

struct Game: View {
    @State private var scene: GameScene = {
        let s = GameScene()
        s.scaleMode = .resizeFill
        return s
    }()

    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
            .onAppear {
                let newScene = GameScene()
                newScene.scaleMode = .resizeFill
                scene = newScene
                GameCenterManager.shared.authenticate()
            }
    }
}

#Preview {
    Game()
        .environment(GameManager())
}
