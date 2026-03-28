//
//  AnimationComponent.swift
//  UnToothAble
//
//  ECS: Stores the animation state of an entity.
//

import Foundation

struct AnimationComponent {
    let animationKey: String
    var isPaused: Bool = false
}
