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
                
                GKAccessPoint.shared.location = .topLeading
                GKAccessPoint.shared.isActive = true
            }
        }
    }
}
