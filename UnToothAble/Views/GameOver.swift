//
//  GameOver.swift
//  UnToothAble
//
//  Created by Rafael Toneto on 16/03/26.
//


import SwiftUI
import UIKit

struct GameOver: View {

    @Environment(GameManager.self) var gameManager

    var score: Int
    var onRestart: () -> Void
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Text("Game Over")
                .font(.system(size: 60, weight: .bold))
                .foregroundStyle(.black)

            Text("Score: \(score)")
                .font(.system(size: 40))
                .foregroundStyle(.black)

            VStack(spacing: 20) {

                Button {
                    showRewardedAndContinue()
                } label: {
                    Text(gameManager.hasUsedReviveThisRun ? "Continue Unavailable" : "Continue Run")
                }
                .buttonStyle(.bordered)
                .disabled(!gameManager.canUseContinue)

                Button("Restart Run") {
                    onRestart()
                    gameManager.goToScene(.game)
                }
                .buttonStyle(.bordered)

                Button("Back to Menu") {
                    gameManager.resetReviveForNewRun()
                    gameManager.gameScene.restartGame()
                    gameManager.goToScene(.home)
                }
                .buttonStyle(.bordered)
            }
            .font(.system(size: 30))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
        .onAppear {
            gameManager.refreshRewardedAvailability()
        }
    }

    private func showRewardedAndContinue() {
        guard gameManager.canUseContinue else { return }
        guard let rootVC = topViewController() else { return }

        gameManager.isShowingRewardedAd = true

        RewardedAdManager.shared.presentAd(
            from: rootVC,
            onRewardEarned: {
                gameManager.markReviveAsUsed()
                gameManager.isShowingRewardedAd = false
                onContinue()
                gameManager.goToScene(.game)
            },
            onFinishedWithoutReward: {
                gameManager.isShowingRewardedAd = false
                gameManager.refreshRewardedAvailability()
            }
        )
    }
    
    private func topViewController(
        base: UIViewController? = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?
            .rootViewController
    ) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
