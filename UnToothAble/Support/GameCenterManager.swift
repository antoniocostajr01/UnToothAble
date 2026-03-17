//
//  Untitled.swift
//  POCcollision
//
//  Created by sofia leitao on 12/03/26.
//
import Foundation
import GameKit
import UIKit

final class GameCenterManager {

    static let shared = GameCenterManager()
    private init() {}

    func authenticate() {
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            if let error {
                print("Erro Game Center:", error.localizedDescription)
                return
            }
            if let viewController {
                guard
                    let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                    let rootVC = windowScene.windows.first?.rootViewController
                else { return }
                rootVC.present(viewController, animated: true)
                return
            }
            if GKLocalPlayer.local.isAuthenticated {
                print("Game Center autenticado:", GKLocalPlayer.local.displayName)
            }
        }
    }

    //salva o score depois do game over
    func submitScore(_ score: Int) {
        guard GKLocalPlayer.local.isAuthenticated else { return }
        Task {
            do {
                try await GKLeaderboard.submitScore(
                    score,
                    context: 0,
                    player: GKLocalPlayer.local,
                    leaderboardIDs: ["grp.untooothable.score"]
                )
            } catch {
                print("Erro ao submeter score:", error.localizedDescription)
            }
        }
    }

    func showLeaderboard() {
        guard GKLocalPlayer.local.isAuthenticated else { return }
        GKAccessPoint.shared.trigger(handler: {})
    }
}
