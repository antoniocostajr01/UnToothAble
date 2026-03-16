//
//  PositionComponent.swift
//  UnToothAble
//
//  ECS: Data-only component for 2D position. Systems read/update this.
//

import CoreGraphics

struct PositionComponent {
    var x: CGFloat
    var y: CGFloat

    var point: CGPoint {
        get { CGPoint(x: x, y: y) }
        set { x = newValue.x; y = newValue.y }
    }

    init(x: CGFloat = 0, y: CGFloat = 0) {
        self.x = x
        self.y = y
    }
}
