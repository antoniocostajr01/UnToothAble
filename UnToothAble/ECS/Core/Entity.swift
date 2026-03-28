//
//  Entity.swift
//  UnToothAble
//
//  ECS: An entity is just a unique ID — behaviour is provided entirely by components.
//

import Foundation

struct Entity: Hashable, Equatable {
    let id: UUID

    init(id: UUID = UUID()) {
        self.id = id
    }
}
