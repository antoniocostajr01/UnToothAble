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

    private let popup = "gameOverPopup"

    private var bestScore: Int {
        LocalScoreStore.shared.bestScore
    }

    private var isFirstDeathInRun: Bool {
        !gameManager.hasUsedReviveThisRun
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.75)
                .ignoresSafeArea()

            ZStack {
                Image(popup)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 382, height: 264)
                    .overlay(alignment: .top) {
                        Text(" SCORE ")
                            .font(.bangers(48))
                            .foregroundStyle(.white)
                            .customStroke(color: Color(.darkBlueStroke), width: 2)
                            .offset(y: -34)
                    }

                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 110)

                    VStack(spacing: 18) {
                        scoreRow(title: " DISTANCE ", value: " \(score) M ")
                        scoreRow(title: " BEST ", value: " \(bestScore) M ")
                    }
                    .frame(maxWidth: 430)

                    Spacer()
                        .frame(height: 70)

                    if isFirstDeathInRun {
                        CustomButton(
                            label: " Continue? (Ad) ",
                            state: .normal,
                            icon: .none,
                            width: 130
                        ) {
                            showRewardedAndContinue()
                        }
                        .overlay(alignment: .topTrailing) {
                            Image("rewardTv")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 21, height: 24)
                                .offset(x: 8, y: -12)
                        }

                    } else {
                        HStack(spacing: 18) {
                            CustomButton(
                                label: "Restart",
                                state: .normal,
                                icon: .restart
                            ) {
                                onRestart()
                                gameManager.goToScene(.game)
                            }

                            CustomButton(
                                label: "Home",
                                state: .normal,
                                icon: .home
                            ) {
                                gameManager.resetReviveForNewRun()
                                gameManager.gameScene.restartGame()
                                gameManager.goToScene(.home)
                            }
                        }
                    }

                    Spacer()
                        .frame(height: 72)
                }
                .frame(width: 690, height: 430)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .onAppear {
            gameManager.refreshRewardedAvailability()
        }
    }
    
    @ViewBuilder
    private func scoreRow(title: String, value: String) -> some View {
        HStack(spacing: 122) {
            Text(title)
                .font(.bangers(22))
                .foregroundStyle(.white)
                .customStroke(color: .black, width: 1)

            Text(value)
                .font(.bangers(22))
                .foregroundStyle(.white)
                .customStroke(color: .black, width: 1)
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
