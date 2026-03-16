//
//  Entity.swift
//  UnToothAble
//
//  ECS: An entity is a unique ID that groups components. It has no behavior—only identity.
//

import Foundation

/// Unique identifier for an entity in the ECS world.
struct Entity: Hashable, Equatable {
    let id: UUID

    init(id: UUID = UUID()) {
        self.id = id
    }
}
