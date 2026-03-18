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
                        Image(systemName: "pause.circle.fill")
                            .font(.system(size: 38))
                            .foregroundStyle(.black.opacity(0.55))
                    }
                    .padding(.top, 52)
                    .padding(.trailing, 20)
                }
                Spacer()
            }

            if showPauseMenu {
                pauseMenu
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
    }

    private var pauseMenu: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("Paused")
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.bottom, 8)

                menuButton(title: "Continue", icon: "play.fill", color: .systemGreen) {
                    showPauseMenu = false
                    gameManager.gameScene.resumeGame()
                }

                menuButton(title: "Restart", icon: "arrow.clockwise", color: .systemBlue) {
                    showPauseMenu = false
                    gameManager.gameScene.resumeGame()
                    gameManager.resetReviveForNewRun()
                    gameManager.gameScene.restartGame()
                }

                menuButton(title: "Home", icon: "house.fill", color: .systemOrange) {
                    showPauseMenu = false
                    gameManager.gameScene.resumeGame()
                    gameManager.resetReviveForNewRun()
                    gameManager.goToScene(.home)
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(white: 0.15))
            )
            .padding(.horizontal, 48)
        }
    }

    @ViewBuilder
    private func menuButton(
        title: String,
        icon: String,
        color: UIColor,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color(color))
            .cornerRadius(14)
        }
    }
}

extension GameScene {

    func pauseGame() {
        guard !isGameOver else { return }
        isPaused = true
    }

    func resumeGame() {
        isPaused = false
        lastUpdateTime = 0
    }
}

#Preview {
    Game()
        .environment(GameManager())
}
