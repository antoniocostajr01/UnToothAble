//
//  JetPackComponent.swift
//  UnToothAble
//
//  ECS: Holds configuration and state for the jetpack logic.
//

import CoreGraphics

struct JetPackComponent {
    let jumpImpulse: CGFloat
    let hoverForce: CGFloat
    let maxFuel: CGFloat
    let fuelConsumptionRate: CGFloat
    let ignitionCost: CGFloat

    var currentFuel: CGFloat
    var isThrusting: Bool

    init(jumpImpulse: CGFloat = 200.0,
         hoverForce: CGFloat = 7000.0,
         maxFuel: CGFloat = 400.0,
         fuelConsumptionRate: CGFloat = 1.8,
         ignitionCost: CGFloat = 5.0,
         currentFuel: CGFloat = 400.0,
         isThrusting: Bool = false) {

        self.jumpImpulse = jumpImpulse
        self.hoverForce = hoverForce
        self.maxFuel = maxFuel
        self.fuelConsumptionRate = fuelConsumptionRate
        self.ignitionCost = ignitionCost
        self.currentFuel = currentFuel
        self.isThrusting = isThrusting
    }
}
