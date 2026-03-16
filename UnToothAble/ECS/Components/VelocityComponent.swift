//
//  VelocityComponent.swift
//  UnToothAble
//
//  ECS: Data-only component for 2D velocity. MovementSystem uses this with PositionComponent.
//

import CoreGraphics

struct VelocityComponent {
    var dx: CGFloat
    var dy: CGFloat

    init(dx: CGFloat = 0, dy: CGFloat = 0) {
        self.dx = dx
        self.dy = dy
    }
}
