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
                    .frame(width: 356, height: 293)

                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 135)

                    HStack(spacing: 20) {
                        statCard(
                            title: " BEST ",
                            value: "\(bestScore) M"
                        )

                        statCard(
                            title: " DISTANCE ",
                            value: "\(score) M"
                        )
                    }

                    Spacer()
                        .frame(height: 27)

                    if isFirstDeathInRun {
                        VStack(spacing: 18) {
                            CustomButton(
                                label: " Continue? (Ad) ",
                                state: .normal,
                                icon: Optional.none,
                                width: 140
                            ) {
                                showRewardedAndContinue()
                            }
                            .overlay(alignment: .topTrailing) {
                                Image("rewardTv")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 27)
                                    .offset(x: 8, y: -14)
                            }

                            Button {
                                gameManager.markReviveAsUsed()
                            } label: {
                                Text(" NO, THANK YOU ")
                                    .font(.bangers(16))
                                    .foregroundStyle(.white)
                                    .customStroke(color: Color(.darkBlueStroke), width: 1)
                            }
                            .buttonStyle(.plain)
                        }

                    } else {
                        HStack(spacing: 22) {
                            CustomButton(
                                label: " Restart ",
                                state: .normal,
                                icon: .restart,
                                width: 125
                            ) {
                                onRestart()
                                gameManager.goToScene(.game)
                            }

                            CustomButton(
                                label: " Menu ",
                                state: .normal,
                                icon: .home,
                                width: 125
                            ) {
                                gameManager.resetReviveForNewRun()
                                gameManager.gameScene.restartGame()
                                gameManager.goToScene(.home)
                            }
                        }
                    }

                    Spacer()
                        .frame(height: isFirstDeathInRun ? 18 : 34)
                }
                .frame(width: 420, height: 300)
                .overlay(alignment: .top) {
                    Text(" SCORE ")
                        .font(.bangers(38))
                        .foregroundStyle(.white)
                        .customStroke(color: Color(.lightBlueStroke), width: 1)
                        .padding(.top, 66)
                }
            }
            .offset(y: -24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .onAppear {
            AudioManager.shared.toggleMute()
            gameManager.refreshRewardedAvailability()
        }
        .onDisappear {
            AudioManager.shared.toggleMute()
        }
    }

    @ViewBuilder
    private func statCard(title: String, value: String, leadingIcon: String? = nil) -> some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.bangers(17))
                .foregroundStyle(.white)
                .customStroke(color: Color(.black), width: 1)

            ZStack {
                Capsule()
                    .fill(Color(.lightBlueCapsule))
                    .frame(width: 124, height: 34)

                Text(" \(value) ")
                    .font(.bangers(22))
                    .foregroundStyle(.white)
                    .customStroke(color: Color(.darkBlueStroke), width: 1.5)
            }
        }
    }

    private func showRewardedAndContinue() {
        guard gameManager.canUseContinue else { return }
        guard let rootVC = topViewController() else { return }

        gameManager.isShowingRewardedAd = true
        gameManager.gameScene.stopAllHaptics()
        AudioManager.shared.pauseMusic()

        RewardedAdManager.shared.presentAd(
            from: rootVC,
            onRewardEarned: {
                gameManager.markReviveAsUsed()
                gameManager.isShowingRewardedAd = false
                gameManager.gameScene.resumeHaptics()
                AudioManager.shared.resumeMusic()
                onContinue()
                gameManager.goToScene(.game)
            },
            onFinishedWithoutReward: {
                gameManager.isShowingRewardedAd = false
                gameManager.refreshRewardedAvailability()
                AudioManager.shared.resumeMusic()
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
