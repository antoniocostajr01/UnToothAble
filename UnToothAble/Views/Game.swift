//
//  Game.swift
//  UnToothAble
//
//  Created by Antonio Costa on 15/03/26.
//

import SpriteKit
import SwiftUI

struct Game: View {

    @Environment(GameManager.self) var gameManager
    @Environment(\.scenePhase) private var scenePhase
    @State private var showPauseMenu = false

    var body: some View {
        ZStack {
            SpriteView(scene: gameManager.gameScene)
                .ignoresSafeArea()

            VStack {
                HStack {
                    Spacer()
                    Button {
                        gameManager.gameScene.pauseGame()
                        showPauseMenu = true
                    } label: {
                        Image(.pauseButton)
                    }
                    .padding(.top, 32)
                    .padding(.trailing, 29)
                }
                Spacer()
            }

            if showPauseMenu {
                PauseMenu(showPauseMenu: $showPauseMenu)
            }
        }
        .onAppear {
            let scene = gameManager.gameScene

            scene.onGameOver = { score in
                gameManager.lastScore = score
                gameManager.refreshRewardedAvailability()
                showPauseMenu = false
                gameManager.goToScene(.gameOver)
            }

            gameManager.restartRun = {
                gameManager.resetReviveForNewRun()
                scene.restartGame()
            }

            gameManager.continueRun = {
                scene.continueRun()
            }

            gameManager.refreshRewardedAvailability()
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .inactive, .background:
                gameManager.gameScene.pauseGame()
                showPauseMenu = true

            case .active:
                if showPauseMenu {
                    gameManager.gameScene.pauseGame()
                }

            @unknown default:
                break
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            gameManager.gameScene.pauseGame()
            showPauseMenu = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            gameManager.gameScene.pauseGame()
            showPauseMenu = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            if showPauseMenu {
                gameManager.gameScene.pauseGame()
            }
        }
        .onDisappear {
            gameManager.gameScene.pauseGame()
            showPauseMenu = true
        }
    }
}

#Preview {
    Game()
        .environment(GameManager())
}
