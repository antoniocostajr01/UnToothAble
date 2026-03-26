//
//  ScoreComponent.swift
//  UnToothAble
//
//  ECS: Data-only component for score tracking.
//

import Foundation

struct ScoreComponent {
    var score: Int = 0
    var accumulator: TimeInterval = 0
}
