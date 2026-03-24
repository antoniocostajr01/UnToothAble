//
//  RewardedAdManager.swift
//  UnToothAble
//
//  Created by Rafael Toneto on 17/03/26.
//

import Foundation
import GoogleMobileAds
import UIKit

@MainActor
final class RewardedAdManager: NSObject, FullScreenContentDelegate {

    static let shared = RewardedAdManager()

    // Test ad unit oficial do Google para Rewarded no iOS
    // Trocar depois pelo seu ad unit real do AdMob
    private let adUnitID = "ca-app-pub-3940256099942544/1712485313"

    private var rewardedAd: RewardedAd?

    private var pendingRewardHandler: (() -> Void)?
    private var pendingFinishWithoutRewardHandler: (() -> Void)?
    private var didEarnReward = false

    var isAdReady: Bool {
        rewardedAd != nil
    }

    override private init() {
        super.init()
    }

    func preloadAd(completion: ((Bool) -> Void)? = nil) {
        let request = Request()

        RewardedAd.load(with: adUnitID, request: request) { [weak self] ad, error in
            guard let self else {
                completion?(false)
                return
            }

            if let error {
                print("Failed to load rewarded ad: \(error.localizedDescription)")
                self.rewardedAd = nil
                completion?(false)
                return
            }

            self.rewardedAd = ad
            self.rewardedAd?.fullScreenContentDelegate = self
            completion?(true)
        }
    }

    func presentAd(
        from viewController: UIViewController,
        onRewardEarned: @escaping () -> Void,
        onFinishedWithoutReward: (() -> Void)? = nil
    ) {
        guard let rewardedAd else {
            onFinishedWithoutReward?()
            return
        }

        self.rewardedAd = nil
        self.pendingRewardHandler = onRewardEarned
        self.pendingFinishWithoutRewardHandler = onFinishedWithoutReward
        self.didEarnReward = false

        rewardedAd.present(from: viewController) { [weak self] in
            self?.didEarnReward = true
        }
    }

    // MARK: - FullScreenContentDelegate

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        if didEarnReward {
            pendingRewardHandler?()
        } else {
            pendingFinishWithoutRewardHandler?()
        }

        clearPendingHandlers()
        preloadAd()
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Failed to present rewarded ad: \(error.localizedDescription)")
        pendingFinishWithoutRewardHandler?()
        clearPendingHandlers()
        preloadAd()
    }

    private func clearPendingHandlers() {
        pendingRewardHandler = nil
        pendingFinishWithoutRewardHandler = nil
        didEarnReward = false
    }
}
