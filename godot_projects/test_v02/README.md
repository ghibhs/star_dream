# 📁 Estrutura do Projeto - Star Dream

## 📂 Organização de Pastas

```
test_v02/
├── 📁 art/                      # Sprites, texturas e recursos visuais
│   ├── arco1.png ~ arco4.png   # Sprites do arco
│   ├── flecha.png              # Sprite da flecha
│   ├── Liron_*.png             # Sprites do personagem principal
│   └── ...                     # Outros assets visuais
│
├── 📁 data_gd/                  # Classes de dados (Resources)
│   ├── EnemyData.gd            # Classe base para dados de inimigos
│   ├── ItemData.gd             # Classe base para dados de items
│   └── WeaponData.gd           # Classe base para dados de armas
│
├── 📁 EnemyData/                # Recursos de inimigos específicos
│   └── wolf_fast.tres          # Dados do lobo veloz
│
├── 📁 ItemData/                 # Recursos de items específicos
│   ├── bow.tres                # Dados do arco
│   └── sword.tres              # Dados da espada
│
├── 📁 scripts/                  # Scripts GDScript organizados
│   ├── 📁 player/              # Scripts do jogador
│   │   ├── entidades.gd        # Controle do player
│   │   └── entidades.gd.uid    # ID único do Godot
│   │
│   ├── 📁 enemy/               # Scripts dos inimigos
│   │   ├── enemy.gd            # Lógica de IA e comportamento
│   │   └── enemy.gd.uid
│   │
│   ├── 📁 items/               # Scripts de items coletáveis
│   │   ├── area_2d.gd          # Lógica de coleta de items
│   │   └── area_2d.gd.uid
│   │
│   ├── 📁 projectiles/         # Scripts de projéteis
│   │   ├── projectile.gd       # Movimento e colisão de projéteis
│   │   └── projectile.gd.uid
│   │
│   ├── 📁 ui/                  # Scripts de interface
│   │   ├── main_menu.gd        # Menu principal
│   │   ├── pause_menu.gd       # Menu de pausa
│   │   ├── game_over.gd        # Tela de game over
│   │   └── *.gd.uid
│   │
│   └── 📁 game/                # Scripts gerais do jogo
│       ├── the_game.gd         # Gerenciamento da cena principal
│       ├── game_stats.gd       # Estatísticas globais (Autoload)
│       └── *.gd.uid
│
├── 📁 scenes/                   # Cenas .tscn organizadas
│   ├── 📁 player/              # Cenas do jogador
│   │   └── entidades.tscn      # Cena do personagem principal
│   │
│   ├── 📁 enemy/               # Cenas de inimigos
│   │   └── enemy.tscn          # Cena base do inimigo
│   │
│   ├── 📁 items/               # Cenas de items
│   │   └── bow.tscn            # Item arco
│   │
│   ├── 📁 projectiles/         # Cenas de projéteis
│   │   └── projectile.tscn     # Projétil básico
│   │
│   ├── 📁 ui/                  # Cenas de interface
│   │   ├── main_menu.tscn      # Menu principal
│   │   ├── pause_menu.tscn     # Menu de pausa
│   │   └── game_over.tscn      # Tela de game over
│   │
│   └── 📁 game/                # Cena principal
│       └── the_game.tscn       # Cena do mundo/level
│
├── 📁 docs/                     # Documentação do projeto
│   ├── BUG_FIX_*.md            # Correções de bugs documentadas
│   ├── CHECKUP_*.md            # Relatórios de verificação
│   ├── COLLISION_SETUP.md      # Sistema de colisão
│   ├── DEBUG_*.md              # Documentação de debug
│   ├── ENEMY_SYSTEM_README.md  # Sistema de inimigos
│   ├── GAME_OVER_SYSTEM.md     # Sistema de game over
│   ├── HITBOX_*.md             # Sistema de hitbox
│   ├── MELEE_ANIMATION_UPDATE.md # Atualização de animações
│   ├── MENU_SYSTEM.md          # Sistema de menus
│   ├── QUICK_START_ENEMIES.md  # Guia rápido de inimigos
│   └── SISTEMA_EMPURRAO.md     # Sistema de empurrão
│
├── 📁 .godot/                   # Cache e arquivos do Godot (gerado automaticamente)
├── 📁 .vscode/                  # Configurações do VS Code
│
├── project.godot                # Arquivo principal do projeto Godot
├── icon.svg                     # Ícone do projeto
└── README.md                    # Este arquivo

```

## 🎯 Convenções de Nomenclatura

### Scripts (.gd)
- **snake_case**: `enemy.gd`, `game_stats.gd`
- **Descritivos**: Nome indica a função do script

### Cenas (.tscn)
- **snake_case**: `enemy.tscn`, `main_menu.tscn`
- **Correspondem aos scripts**: Mesmo nome base quando aplicável

### Resources (.tres)
- **snake_case**: `wolf_fast.tres`, `bow.tres`
- **Descritivos**: Indicam o tipo de recurso

### Classes (class_name)
- **PascalCase**: `Enemy_Data`, `Weapon_Data`, `Item_Data`
- **Sufixo _Data**: Para classes de recursos

## 🔍 Localização Rápida

### Quer modificar...

**Movimento do jogador?**
→ `scripts/player/entidades.gd`

**IA do inimigo?**
→ `scripts/enemy/enemy.gd`

**Menu principal?**
→ `scripts/ui/main_menu.gd` + `scenes/ui/main_menu.tscn`

**Stats de um inimigo?**
→ `EnemyData/wolf_fast.tres`

**Sistema de colisão?**
→ `docs/COLLISION_SETUP.md`

**Sistema de empurrão?**
→ `docs/SISTEMA_EMPURRAO.md`

## 📋 Sistemas Principais

### 1. Sistema de Camadas de Colisão
- **Layer 1**: World (cenário)
- **Layer 2**: Player
- **Layer 3**: Enemy
- **Layer 4**: Player Hitbox
- **Layer 5**: Enemy Hitbox
- **Layer 6**: Projectiles

📖 Detalhes: `docs/COLLISION_SETUP.md`

### 2. Sistema de Inimigos
- Máquina de estados (IDLE, CHASE, ATTACK, HURT, DEAD)
- Sistema de detecção por range
- Dados configuráveis via Resources

📖 Detalhes: `docs/ENEMY_SYSTEM_README.md`

### 3. Sistema de Empurrão
- Jogador pode empurrar inimigos fracos
- Inimigos fortes bloqueiam o jogador
- Configurável por `push_force` em cada inimigo

📖 Detalhes: `docs/SISTEMA_EMPURRAO.md`

### 4. Sistema de Menus
- Menu Principal (start, options, quit)
- Pause Menu (ESC para pausar)
- Game Over (restart, menu, quit)

📖 Detalhes: `docs/MENU_SYSTEM.md`

### 5. Sistema de Stats
- GameStats (Autoload)
- Rastreamento de kills, tempo de jogo
- Persistência entre cenas

📖 Detalhes: `scripts/game/game_stats.gd`

## 🚀 Começando

1. **Abra o projeto no Godot** (versão 4.5+)
2. **Cena principal**: `scenes/ui/main_menu.tscn`
3. **Pressione F5** para rodar

## 🛠️ Autoloads Configurados

- **GameStats**: `scripts/game/game_stats.gd`
  - Gerencia estatísticas globais do jogo

## 📝 Notas Importantes

- **Não edite arquivos .uid**: São gerados automaticamente pelo Godot
- **Cache .godot/**: Pode ser deletado se necessário
- **Temporários**: Arquivos `.tmp` podem ser ignorados
- **Assets**: Sempre mantenha os `.import` junto aos assets

## 🔄 Atualizações Recentes

- ✅ Organização em pastas scripts/ e scenes/
- ✅ Documentação movida para docs/
- ✅ Sistema de empurrão implementado
- ✅ Menu system completo
- ✅ Correção de bugs de colisão

## 📞 Referência Rápida de Pastas

| Tipo | Pasta | Descrição |
|------|-------|-----------|
| Scripts | `scripts/` | Todos os arquivos .gd |
| Cenas | `scenes/` | Todos os arquivos .tscn |
| Docs | `docs/` | Toda documentação .md |
| Assets | `art/` | Sprites e texturas |
| Dados | `data_gd/` | Classes de recursos |
| Recursos | `*Data/` | Arquivos .tres específicos |

---

**Última atualização**: Organização completa do projeto
**Versão**: test_v02 (thirdversion)
