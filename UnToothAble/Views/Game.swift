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
                handleAppBecameInactive()

            case .active:
                handleAppBecameActive()

            @unknown default:
                break
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            handleAppBecameInactive()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            handleAppBecameInactive()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            handleAppBecameActive()
        }
        .onDisappear {
            gameManager.gameScene.pauseGame()
            showPauseMenu = true
        }
    }

    private func handleAppBecameInactive() {
        guard !gameManager.isShowingRewardedAd else { return }
        gameManager.gameScene.pauseGame()
        showPauseMenu = true
    }

    private func handleAppBecameActive() {
        guard !gameManager.isShowingRewardedAd else { return }

        if showPauseMenu {
            gameManager.gameScene.pauseGame()
        }
    }
}

#Preview {
    Game()
        .environment(GameManager())
}
