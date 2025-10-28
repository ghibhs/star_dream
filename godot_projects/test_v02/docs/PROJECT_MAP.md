# 🗺️ Mapa Visual do Projeto

## 📦 Estrutura Completa

```
test_v02/                                    🎮 PROJETO GODOT
│
├── 📁 art/                                  🎨 ASSETS VISUAIS
│   ├── arco1.png ~ arco4.png               🏹 Sprites do arco (4 frames)
│   ├── flecha.png                          🔻 Sprite da flecha
│   ├── lanca.png                           🗡️ Sprite da lança
│   ├── Liron_*.png (9 arquivos)            🧍 Personagem principal (8 direções + base)
│   ├── Arvore.png                          🌳 Cenário
│   ├── mesa.png                            🪑 Objeto
│   ├── moeda_game1.png                     🪙 Moeda
│   └── black_wolf_32x32_spritesheet.png    🐺 Spritesheet do lobo
│
├── 📁 data_gd/                             💾 CLASSES DE DADOS
│   ├── EnemyData.gd                        👾 class_name Enemy_Data
│   ├── ItemData.gd                         📦 class_name Item_Data
│   └── WeaponData.gd                       ⚔️ class_name Weapon_Data
│
├── 📁 EnemyData/                           🎭 RECURSOS DE INIMIGOS
│   └── wolf_fast.tres                      🐺 Lobo Veloz
│       ├── HP: 30                          ❤️ Vida
│       ├── Damage: 15                      💥 Dano
│       ├── Speed: 80                       🏃 Velocidade
│       ├── Push Force: 60                  💨 Resistência (empurrável)
│       └── Chase Range: 300                👁️ Alcance de detecção
│
├── 📁 ItemData/                            🎁 RECURSOS DE ITEMS
│   ├── bow.tres                            🏹 Arco
│   └── sword.tres                          🗡️ Espada
│
├── 📁 scripts/                             📜 SCRIPTS ORGANIZADOS
│   │
│   ├── 📁 player/                          🧍 JOGADOR
│   │   ├── entidades.gd                    🎮 Controle do player
│   │   │   ├── Movimento (WASD)            ⌨️
│   │   │   ├── Animações (8 direções)      🎬
│   │   │   ├── Sistema de armas            🏹
│   │   │   ├── Sistema de saúde            ❤️
│   │   │   └── Sistema de empurrão         💪
│   │   └── entidades.gd.uid                🆔
│   │
│   ├── 📁 enemy/                           👾 INIMIGOS
│   │   ├── enemy.gd                        🧠 IA do inimigo
│   │   │   ├── Estados (5):                📊
│   │   │   │   ├── IDLE                    😴 Parado
│   │   │   │   ├── CHASE                   🏃 Perseguindo
│   │   │   │   ├── ATTACK                  ⚔️ Atacando
│   │   │   │   ├── HURT                    😵 Machucado
│   │   │   │   └── DEAD                    💀 Morto
│   │   │   ├── Detecção por range          👁️
│   │   │   ├── Sistema de ataque           💥
│   │   │   ├── Sistema de empurrão         💨
│   │   │   └── Sistema de morte            ☠️
│   │   └── enemy.gd.uid                    🆔
│   │
│   ├── 📁 items/                           📦 ITEMS COLETÁVEIS
│   │   ├── area_2d.gd                      ✨ Lógica de coleta
│   │   │   ├── Detecção de player          👁️
│   │   │   ├── Equipar arma                🔧
│   │   │   └── Feedback visual             ✅
│   │   └── area_2d.gd.uid                  🆔
│   │
│   ├── 📁 projectiles/                     🔻 PROJÉTEIS
│   │   ├── projectile.gd                   💨 Movimento e colisão
│   │   │   ├── Velocidade constante        🚀
│   │   │   ├── Detecção de inimigos        🎯
│   │   │   ├── Sistema de dano             💥
│   │   │   └── Auto-destruição             💣
│   │   └── projectile.gd.uid               🆔
│   │
│   ├── 📁 ui/                              🖥️ INTERFACE
│   │   ├── main_menu.gd                    🏠 Menu principal
│   │   │   ├── Iniciar Jogo                ▶️
│   │   │   ├── Opções                      ⚙️
│   │   │   └── Sair                        🚪
│   │   ├── pause_menu.gd                   ⏸️ Menu de pausa
│   │   │   ├── Continuar                   ▶️
│   │   │   ├── Reiniciar                   🔄
│   │   │   ├── Menu Principal              🏠
│   │   │   └── Sair                        🚪
│   │   ├── game_over.gd                    💀 Tela de morte
│   │   │   ├── Restart                     🔄
│   │   │   ├── Menu                        🏠
│   │   │   └── Quit                        🚪
│   │   └── *.gd.uid                        🆔
│   │
│   └── 📁 game/                            🎮 GERENCIAMENTO
│       ├── the_game.gd                     🌍 Controle da cena principal
│       ├── game_stats.gd (AUTOLOAD)        📊 Stats globais
│       │   ├── enemies_defeated            💀 Inimigos mortos
│       │   ├── survival_time               ⏱️ Tempo de jogo
│       │   └── reset()                     🔄 Reiniciar
│       └── *.gd.uid                        🆔
│
├── 📁 scenes/                              🎬 CENAS ORGANIZADAS
│   │
│   ├── 📁 player/                          🧍
│   │   └── entidades.tscn                  Player completo
│   │       ├── AnimatedSprite2D            🎨
│   │       ├── CollisionShape2D            🔲
│   │       ├── WeaponMarker2D              🏹
│   │       └── Timers                      ⏱️
│   │
│   ├── 📁 enemy/                           👾
│   │   └── enemy.tscn                      Inimigo base
│   │       ├── AnimatedSprite2D            🎨
│   │       ├── CollisionShape2D            🔲
│   │       ├── DetectionArea2D             👁️
│   │       ├── HitboxArea2D                💥
│   │       └── Timers                      ⏱️
│   │
│   ├── 📁 items/                           📦
│   │   └── bow.tscn                        Item arco
│   │       ├── Area2D                      ✨
│   │       └── Sprite2D                    🎨
│   │
│   ├── 📁 projectiles/                     🔻
│   │   └── projectile.tscn                 Projétil
│   │       ├── Area2D                      💥
│   │       └── Sprite2D                    🎨
│   │
│   ├── 📁 ui/                              🖥️
│   │   ├── main_menu.tscn                  Menu principal
│   │   │   └── CanvasLayer → Buttons       🔘
│   │   ├── pause_menu.tscn                 Menu pausa
│   │   │   └── CanvasLayer → Buttons       🔘
│   │   └── game_over.tscn                  Game over
│   │       └── CanvasLayer → Labels+Btns   🔘
│   │
│   └── 📁 game/                            🌍
│       └── the_game.tscn                   Mundo/Level
│           ├── Entidades (player)          🧍
│           ├── Enemy                       👾
│           ├── Items                       📦
│           ├── TileMapLayer                🗺️
│           ├── Camera2D                    📷
│           └── PauseMenu                   ⏸️
│
├── 📁 docs/                                📚 DOCUMENTAÇÃO (16 arquivos)
│   ├── INDEX.md                            📋 Este arquivo - índice principal
│   ├── BUG_FIX_*.md (2)                    🐛 Correções de bugs
│   ├── CHECKUP_*.md (2)                    ✅ Verificações
│   ├── COLLISION_SETUP.md                  🎯 Sistema de colisão
│   ├── DEBUG_*.md (3)                      🔍 Debug
│   ├── ENEMY_SYSTEM_README.md              👾 Sistema de inimigos
│   ├── GAME_OVER_SYSTEM.md                 💀 Sistema de morte
│   ├── HITBOX_*.md (2)                     💥 Sistema de hitbox
│   ├── MELEE_ANIMATION_UPDATE.md           🎬 Animações
│   ├── MENU_SYSTEM.md                      🖥️ Sistema de menus
│   ├── QUICK_START_ENEMIES.md              🚀 Guia rápido
│   └── SISTEMA_EMPURRAO.md                 💨 Sistema de empurrão
│
├── 📄 project.godot                        ⚙️ CONFIGURAÇÃO PRINCIPAL
│   ├── Autoloads:                          🔄
│   │   └── GameStats                       📊
│   └── Input Map:                          🎮
│       ├── ui_left/right/up/down           ⌨️
│       └── ui_cancel (ESC)                 ⏸️
│
├── 📄 README.md                            📖 DOCUMENTAÇÃO RAIZ
└── 📄 icon.svg                             🎨 Ícone do projeto

```

## 🎯 Sistema de Camadas de Colisão

```
Layer 1  (1)    🧱 WORLD          Cenário/obstáculos
Layer 2  (2)    🧍 PLAYER         Corpo do jogador
Layer 3  (4)    👾 ENEMY          Corpo dos inimigos
Layer 4  (16)   ⚔️ PLAYER_HITBOX  Área de ataque do player
Layer 5  (8)    💥 ENEMY_HITBOX   Área de ataque dos inimigos
Layer 6  (32)   🔻 PROJECTILE     Projéteis (flechas, etc)
```

### Interações:

```
PLAYER (Layer 2)        detecta → World(1) + Enemy(4) + Enemy Hitbox(8)
ENEMY (Layer 4)         detecta → World(1) + Player(2) + Player Hitbox(16)
PLAYER HITBOX (Layer 16) detecta → Enemy(4)
ENEMY HITBOX (Layer 8)   detecta → Player(2)
PROJECTILE (Layer 32)    detecta → Enemy(4)
```

## 🔄 Fluxo de Jogo

```
🏠 Main Menu
    ↓ [INICIAR JOGO]
    ↓
🌍 The Game (gameplay)
    ├── [ESC] → ⏸️ Pause Menu
    │           ├── [CONTINUAR] → volta ao jogo
    │           ├── [REINICIAR] → reload the_game
    │           ├── [MENU] → main_menu
    │           └── [SAIR] → quit
    │
    └── [MORTE] → 💀 Game Over
                ├── [RESTART] → reload the_game
                ├── [MENU] → main_menu
                └── [QUIT] → quit
```

## 💪 Sistema de Empurrão

```
Player Strength: 100

Inimigo     | Push Force | Resultado
------------|------------|--------------------
Slime       | 120        | ✅ Muito empurrável
Goblin      | 100        | ✅ Empurrável
Lobo        | 60         | ✅ Empurrável
Orc         | 40         | ⚠️ Difícil
Cavaleiro   | 20         | ⚠️ Muito difícil
Boss/Golem  | 0          | ❌ Imóvel (bloqueia)

Cálculo: push_power = (100 - push_force) * 0.5
```

## 🧠 Estados do Inimigo

```
IDLE 😴
  ↓ [player detectado]
  ↓
CHASE 🏃
  ├─ Persegue player
  └─ [chegou perto] → ATTACK

ATTACK ⚔️
  ├─ Causa dano
  ├─ [longe] → CHASE
  └─ [morreu] → DEAD

HURT 😵
  ├─ Flash vermelho
  └─ [timer] → CHASE

DEAD 💀
  └─ Remove da cena
```

## 📊 Estatísticas Principais

- **Total de Scripts**: 11 arquivos .gd
- **Total de Cenas**: 9 arquivos .tscn
- **Total de Documentos**: 17 arquivos .md
- **Resources (Data)**: 3 classes base + 3 instances
- **Assets Visuais**: ~20 arquivos
- **Camadas de Colisão**: 6 layers configuradas

---

**Projeto**: Star Dream
**Versão**: test_v02 (thirdversion)
**Engine**: Godot 4.5.dev4
**Última Atualização**: Organização completa ✨
