//
//  JetPackComponent.swift
//  UnToothAble
//
//  ECS: Holds configuration and state for the jetpack logic.
//

import CoreGraphics

struct JetPackComponent {
    let hoverForce: CGFloat
    let maxFuel: CGFloat
    let fuelConsumptionRate: CGFloat
    let ignitionCost: CGFloat

    var currentFuel: CGFloat
    var isThrusting: Bool
    var rechargeRate: CGFloat
    var isRecharging: Bool

    init(hoverForce: CGFloat = 1500.0,
         maxFuel: CGFloat = 150.0,
         fuelConsumptionRate: CGFloat = 30.0,
         ignitionCost: CGFloat = 4.0,
         currentFuel: CGFloat = 150.0,
         isThrusting: Bool = false,
         rechargeRate: CGFloat = 40.0,
         isRecharging: Bool = false) {

        self.hoverForce = hoverForce
        self.maxFuel = maxFuel
        self.fuelConsumptionRate = fuelConsumptionRate
        self.ignitionCost = ignitionCost
        self.currentFuel = currentFuel
        self.isThrusting = isThrusting
        self.rechargeRate = rechargeRate
        self.isRecharging = isRecharging
    }
}
