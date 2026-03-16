//
//  SpriteComponent.swift
//  UnToothAble
//
//  ECS: Liga uma entidade ao nó SpriteKit que a representa na tela. Usado para sincronizar PositionComponent ↔ node.position.
//

import SpriteKit

/// Guarda a referência ao SKNode que representa esta entidade na cena. Permite aos sistemas atualizar a posição visual a partir do ECS.
struct SpriteComponent {
    let node: SKNode
}
