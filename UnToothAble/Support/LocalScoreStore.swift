//
//  Untitled.swift
//  POCcollision
//
//  Created by sofia leitao on 12/03/26.
//
import Foundation

final class LocalScoreStore {
    static let shared = LocalScoreStore()
    
    private init() {}
    
    private let bestScoreKey = "best_score_local"
    
    var bestScore: Int {
        UserDefaults.standard.integer(forKey: bestScoreKey)
    }
    
    func saveIfNeeded(score: Int) {
        if score > bestScore {
            UserDefaults.standard.set(score, forKey: bestScoreKey)
        }
    }
}
