//
//  HapticsManager.swift
//  UnToothAble
//
//  Centralized haptic feedback manager, extracted from GameScene.
//

import UIKit

final class HapticsManager {

    private let jumpHaptic = UIImpactFeedbackGenerator(style: .light)
    private let jetpackHaptic = UIImpactFeedbackGenerator(style: .soft)
    private let hitHaptic = UINotificationFeedbackGenerator()

    private var jetpackHapticAccumulator: TimeInterval = 0
    private let jetpackHapticInterval: TimeInterval = 0.12
    private(set) var shouldAllowHaptics = true

    private var isHapticsEnabled: Bool {
        UserDefaults.standard.object(forKey: "hapticsEnabled") as? Bool ?? true
    }

    func prepare() {
        guard isHapticsEnabled, shouldAllowHaptics else { return }
        jumpHaptic.prepare()
        jetpackHaptic.prepare()
        hitHaptic.prepare()
    }

    func triggerJump() {
        guard isHapticsEnabled, shouldAllowHaptics else { return }
        jumpHaptic.impactOccurred(intensity: 0.75)
        jumpHaptic.prepare()
    }

    func triggerJetpack() {
        guard isHapticsEnabled, shouldAllowHaptics else { return }
        jetpackHaptic.impactOccurred(intensity: 0.45)
        jetpackHaptic.prepare()
    }

    func triggerHit() {
        guard isHapticsEnabled, shouldAllowHaptics else { return }
        hitHaptic.notificationOccurred(.error)
        hitHaptic.prepare()
    }

    func updateJetpackHaptics(deltaTime: TimeInterval, isThrusting: Bool, hasFuel: Bool) {
        guard shouldAllowHaptics else {
            jetpackHapticAccumulator = 0
            return
        }

        guard isThrusting, hasFuel else {
            jetpackHapticAccumulator = 0
            return
        }

        jetpackHapticAccumulator += deltaTime

        if jetpackHapticAccumulator >= jetpackHapticInterval {
            jetpackHapticAccumulator = 0
            triggerJetpack()
        }
    }

    func stopAll() {
        shouldAllowHaptics = false
        jetpackHapticAccumulator = 0
    }

    func resume() {
        shouldAllowHaptics = true
        jetpackHapticAccumulator = 0
        prepare()
    }
}
