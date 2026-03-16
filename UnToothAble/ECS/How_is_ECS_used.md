# Como a ECS é usada na GameScene

Este ficheiro explica **quem chama o quê** e em que ordem, para o fluxo da arquitetura Entity-Component-System no UnToothAble.

---

## 1. Início da cena (`didMove(to:)`)

Quando a cena é apresentada:

1. **GameScene** cria o **World** (ECS):  
   `ecsWorld = World()` (já vem inicializado na propriedade).

2. **GameScene** cria o **ScrollSystem** com a velocidade do cenário:  
   `scrollSystem = ScrollSystem(scenarioSpeed: GameConstants.Physics.scenarioSpeed)`.

3. **GameScene** chama `setupPlayer()`:
   - Cria o nó SpriteKit do jogador e adiciona à cena.
   - Chama **PlayerFactory**:  
     `PlayerFactory.create(in: ecsWorld)`  
     → cria uma **Entity** com `PositionComponent` e `VelocityComponent`.
   - A **GameScene** adiciona à mesma entidade:
     - `PositionComponent` com a posição inicial do jogador.
     - `SpriteComponent(node: player)` para ligar a entidade ao nó do dente.
   - Guarda a entidade em `playerEntity`.

4. O spawn de obstáculos fica agendado com `startSpawningObstacles()` (ações SpriteKit).

---

## 2. Cada vez que nasce um obstáculo (`spawnObstacle()`)

1. **GameScene** cria o **SKSpriteNode** do obstáculo e adiciona ao `worldNode`.

2. **GameScene** chama **ObstacleFactory**:  
   `ObstacleFactory.create(in: ecsWorld, at: spawnPosition)`  
   → cria uma **Entity** com `PositionComponent` e `ObstacleComponent`.

3. **GameScene** adiciona à entidade:  
   `SpriteComponent(node: obstacle)`  
   → fica a haver uma entidade por obstáculo, com posição e referência ao nó.

---

## 3. Em cada frame (`update(_:)`)

A ordem é importante:

1. **Sincronizar jogador (SpriteKit → ECS)**  
   `syncPlayerPositionFromNode()`  
   - Lê `player.position` (actualizado pela física do SpriteKit).  
   - Escreve no `PositionComponent` da entidade do jogador.  
   - Assim, o ECS fica a saber onde está o jogador (útil para futuros sistemas, ex.: pontuação, IA).

2. **Rodar o sistema de scroll**  
   `scrollSystem.update(world: ecsWorld, deltaTime: deltaTime)`  
   - O **ScrollSystem** percorre todas as entidades com `ObstacleComponent` e `PositionComponent`.  
   - Para cada uma, faz `PositionComponent.x -= scenarioSpeed * deltaTime`.  
   - O movimento dos obstáculos passa a ser **liderado pelo ECS**.

3. **Sincronizar ECS → nós (SpriteKit)**  
   `syncPositionToNodes()`  
   - Para cada entidade que tem `SpriteComponent` e `PositionComponent`:  
     `sprite.node.position = positionComponent.point`.  
   - Os obstáculos (e, de forma redundante, o jogador) passam a ter a posição visual igual à posição no ECS.

4. **Chão e limpeza**  
   - `moveGroundOnly(deltaTime:)`: move apenas os nós do chão (não estão no ECS).  
   - `recycleGround()`: recicla as tiras de chão.  
   - `removeOffscreenObstacles()`:  
     - Percorre entidades com `ObstacleComponent` + `SpriteComponent` + `PositionComponent`.  
     - Se `position.x < -100`, remove o nó da cena e chama `ecsWorld.removeEntity(entity)`.

5. **Background**  
   `background.update(deltaTime:scenarioSpeed:)` — continua igual, fora do ECS.

---

## 4. Reinício (`restartGame()`)

1. **GameScene** limpa nós e ações como antes.

2. **GameScene** recria o mundo e o sistema:  
   `ecsWorld = World()`  
   `scrollSystem = ScrollSystem(scenarioSpeed: ...)`  
   Assim todas as entidades antigas (obstáculos) desaparecem.

3. **GameScene** chama de novo `setupPlayer()`, que volta a usar **PlayerFactory** e a criar uma nova entidade do jogador.

---

## Resumo do fluxo de chamadas

| Quem        | Chama                         | Quando / O quê |
|------------|--------------------------------|----------------|
| GameScene  | `PlayerFactory.create(in:)`    | Em `setupPlayer()` (início e restart). |
| GameScene  | `ObstacleFactory.create(in:at:)`| Em `spawnObstacle()` cada vez que nasce um obstáculo. |
| GameScene  | `scrollSystem.update(world:deltaTime:)` | Em cada `update(_:)`, depois de sincronizar o jogador. |
| GameScene  | `syncPlayerPositionFromNode()` | Em cada `update(_:)` — node → ECS. |
| GameScene  | `syncPositionToNodes()`        | Em cada `update(_:)` — ECS → nós. |
| GameScene  | `ecsWorld.removeEntity(_:)`    | Em `removeOffscreenObstacles()` para obstáculos fora do ecrã. |

O **MovementSystem** (que actualiza posição a partir de velocidade) não é usado na GameScene actual porque o jogador é movido pela **física do SpriteKit**; a velocidade no ECS está disponível para quando quiseres lógica extra (ex.: um sistema que use velocidade para efeitos ou som).
