//
//  World.swift
//  UnToothAble
//
//  ECS: The world holds all entities and their components. Systems query the world to process entities.
//

import Foundation

/// Manages entities and their associated components. Systems operate on this world each frame.
final class World {
    private var entities: Set<Entity> = []
    private var components: [Entity: [String: Any]] = [:]

    func createEntity() -> Entity {
        let entity = Entity()
        entities.insert(entity)
        components[entity] = [:]
        return entity
    }

    func removeEntity(_ entity: Entity) {
        entities.remove(entity)
        components.removeValue(forKey: entity)
    }

    func addComponent<T>(_ component: T, to entity: Entity) where T: Any {
        let key = String(describing: T.self)
        components[entity, default: [:]][key] = component
    }

    func component<T>(_ type: T.Type, for entity: Entity) -> T? {
        let key = String(describing: T.self)
        return components[entity]?[key] as? T
    }

    func entities(with componentTypes: [Any.Type]) -> [Entity] {
        let keys = Set(componentTypes.map { String(describing: $0) })
        return entities.filter { entity in
            guard let entityComps = components[entity] else { return false }
            return keys.isSubset(of: Set(entityComps.keys))
        }
    }

    var allEntities: [Entity] { Array(entities) }
}
