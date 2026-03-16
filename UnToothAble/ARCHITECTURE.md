# Arquitetura do projeto UnToothAble

Este documento descreve a estrutura de pastas e a responsabilidade de cada camada do projeto, incluindo a navegação personalizada baseada numa view root e a organização ECS (Entity–Component–System).

---

## Visão geral

O projeto está organizado em camadas com responsabilidades bem definidas:

- **App** – Ponto de entrada da aplicação.
- **Views** – Parte visual e navegação personalizada (view root + ecrãs).
- **Scenes** – Orquestração do SpriteKit e ligação ao ECS.
- **ECS** – Motor de dados e regras do jogo (Entity–Component–System).
- **Factories** – Criação de entidades com os componentes corretos.
- **Support** – Constantes, persistência, Game Center e utilitários.
- **Enums** – Tipos enumerados partilhados (ex.: fluxo de navegação).
- **Assets** – Recursos visuais (imagens, cores, ícone).

---

## Responsabilidade de cada camada

### App

**Responsabilidade:** Ponto de entrada da aplicação e configuração da janela.

- **UnToothAbleApp.swift** – Estrutura com `@main` que arranca a app e define o primeiro conteúdo apresentado (por exemplo `Root()` ou `Home()`).
- **UnToothAble.entitlements** – Permissões e capacidades da app.
- **Assets.xcassets** (quando está aqui) – Catálogo de assets da aplicação.

Não contém lógica de jogo nem de navegação; apenas inicia a app e mostra a view raiz.

---

### Views

**Responsabilidade:** Parte visual da interface e **navegação personalizada** (sem empilhamento de ecrãs).

Esta pasta concentra as vistas SwiftUI que o utilizador vê e a lógica de "qual ecrã está activo", usando uma **view root** com um `ZStack` que troca o conteúdo consoante a seleção, em vez de `NavigationStack` + push/pop.

- **Root.swift** – **View root** da aplicação. Contém um `ZStack` que, consoante o estado em `GameManager.currentScene` (ex.: `GameDelegator`), mostra uma de três vistas: `Home`, `Settings` ou `Game`. O `GameManager` é injetado via `.environment(gameManager)` para que as vistas filhas possam mudar de "ecrã" chamando `gameManager.goToScene(_:)`.
- **Home.swift** – Ecrã inicial (menu, título, botão Play). Navega para o jogo com `gameManager.goToScene(.game)`.
- **Game.swift** – Vista que apresenta o jogo: envolve a `GameScene` num `SpriteView(scene:)` e trata do ciclo de vida da cena (ex.: criar nova cena em `onAppear`).
- **Settings.swift** – Ecrã de definições.

Resumo: **Views** é a camada que desenha os ecrãs e controla **qual deles está visível** através da root e do `GameManager`, sem navegação em stack.

---

### Scenes

**Responsabilidade:** Orquestrar o SpriteKit e fazer a ponte entre a apresentação (nós, física) e o ECS.

- **GameScene** – Cena principal do jogo: cria o `World`, usa as Factories para jogador e obstáculos, chama os sistemas no `update`, sincroniza dados ECS ↔ nós (ex.: `syncPlayerPositionFromNode`, `syncPositionToNodes`), gere toques, HUD, game over e restart.
- **EnemyScene** / **JetPackPhysics** – Outras cenas ou protótipos de gameplay.
- **ScrollingBackground** – Nó que desenha e anima o fundo em scroll; usado pela GameScene.

Ou seja: tudo o que depende de `SKScene`/`SKView` e do ciclo de jogo por frame vive aqui; a vista **Game** (em Views) apenas mostra a cena.

---

### ECS (Entity–Component–System)

**Responsabilidade:** Modelo de dados e regras do jogo, independente da apresentação.

#### ECS/Core

- **Entity** – Identificador único (ex.: UUID) que representa "uma coisa no jogo".
- **World** – Repositório de entidades e componentes: criar/remover entidades, adicionar/consultar componentes. Sistemas e cena usam o World para ler e alterar estado.

#### ECS/Components

- **PositionComponent** – Posição 2D (x, y).
- **VelocityComponent** – Velocidade 2D (dx, dy).
- **SpriteComponent** – Referência ao `SKNode` que desenha a entidade.
- **ObstacleComponent** – "Tag" que marca a entidade como obstáculo (usado pelo ScrollSystem).

Componentes são só dados; não contêm lógica.

#### ECS/Systems

- **MovementSystem** – Atualiza posição a partir da velocidade (Position + Velocity).
- **ScrollSystem** – Para entidades com `ObstacleComponent`, move a posição no eixo X (scroll do cenário).

Sistemas contêm a lógica que corre cada frame (ou quando necessário) sobre as entidades que têm os componentes adequados.

---

### Factories

**Responsabilidade:** Criar entidades já com os componentes corretos, para a cena não montar tudo à mão.

- **PlayerFactory** – Cria a entidade do jogador com `PositionComponent` e `VelocityComponent`; a cena adiciona depois `SpriteComponent` e posição inicial.
- **ObstacleFactory** – Cria a entidade do obstáculo com `PositionComponent` e `ObstacleComponent`; a cena adiciona `SpriteComponent` ao spawear o nó.

---

### Support

**Responsabilidade:** Configuração, persistência e utilitários partilhados.

- **GameConstants** – Constantes do jogo (gravidade, velocidade, categorias de física, layout, nomes de assets).
- **GameManager** – Estado global de navegação: `currentScene` (ex.: `GameDelegator`) e `goToScene(_:)`. Usado pela **Views** (Root e ecrãs) para trocar o conteúdo do ZStack.
- **GameCenterManager** – Autenticação e integração com Game Center.
- **LocalScoreStore** – Persistência da melhor pontuação (ex.: UserDefaults).
- **ImagePlaceholder** – Vista SwiftUI reutilizável para exibir uma imagem.

---

### Enums

**Responsabilidade:** Tipos enumerados partilhados entre camadas.

- **GameDelegator** – Define os "ecrãs" da navegação personalizada (ex.: `.home`, `.settings`, `.game`). Usado por `GameManager` e pela **Root** para decidir o que mostrar no ZStack.

---

### Assets (Assets.xcassets)

**Responsabilidade:** Recursos visuais (imagens, cores, ícone da app). Sem lógica; apenas gestão de assets.

---

## Fluxo da navegação personalizada

1. A app arranca e mostra a view root (**Root**).
2. **Root** usa um `ZStack` e um `switch` em `gameManager.currentScene` (ex.: `GameDelegator`) para mostrar **Home**, **Settings** ou **Game**.
3. Em **Home**, o utilizador toca em "Play" e chama `gameManager.goToScene(.game)`.
4. **GameManager** atualiza `currentScene`; o **Root** re-renderiza e passa a mostrar **Game** no ZStack.
5. **Game** contém `SpriteView(scene: gameScene)` e trata do ciclo de vida da **GameScene**.

Não há push/pop de navegação; apenas troca de qual vista está visível no ZStack, com estado gerido pelo **GameManager** e partilhado via `@Environment`.

---

## Resumo em tabela

| Camada        | Responsabilidade em uma frase |
|---------------|--------------------------------|
| **App**       | Entrada da app e configuração da janela. |
| **Views**     | Parte visual e navegação personalizada (view root + ZStack + ecrãs). |
| **Scenes**    | SpriteKit, ciclo de jogo e ligação ECS ↔ ecrã. |
| **ECS/Core**  | Definição de entidade e repositório de estado (World). |
| **ECS/Components** | Dados por entidade (posição, velocidade, nó, tags). |
| **ECS/Systems**   | Regras que atualizam esses dados (movimento, scroll). |
| **Factories** | Criação de entidades com os componentes corretos. |
| **Support**   | Constantes, GameManager, persistência, Game Center, helpers. |
| **Enums**     | Tipos enumerados partilhados (ex.: ecrãs da navegação). |
| **Assets**    | Imagens, cores, ícone. |

---

*Documento gerado para descrever a estrutura do projeto UnToothAble e a responsabilidade de cada camada, incluindo a pasta Views e a navegação personalizada.*
