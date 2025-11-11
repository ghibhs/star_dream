# 🎮 Star Dream - Projeto de Jogo Godot

> **Projeto Acadêmico** - Sistema de combate RPG com inimigos, magias e inventário

## 👥 Equipe do Projeto
> **IMPORTANTE**: Substitua os nomes abaixo pelos nomes reais da equipe antes de entregar!

- **[Nome Completo 1]** - Desenvolvedor Principal / Programação
- **[Nome Completo 2]** - Desenvolvedor / Sistema de Combate
- **[Nome Completo 3]** - Game Design / Arte
- **[Nome Completo 4]** - Tester / Documentação

---

## 🚀 Como Baixar e Rodar o Projeto

### 📋 Pré-requisitos

1. **Godot Engine 4.5+** (Dev4 ou superior)
   - Download: https://godotengine.org/download
   - **Importante**: Use a versão **4.5 ou superior** (o projeto foi desenvolvido em 4.5.dev4)

2. **Git** (para clonar o repositório)
   - Download: https://git-scm.com/downloads

### 📥 Passo a Passo para Instalação

#### Opção 1: Clonar via Git (Recomendado)

```bash
# 1. Abra o terminal/prompt de comando

# 2. Navegue até a pasta onde deseja salvar o projeto
cd C:\Users\SeuUsuario\Documents

# 3. Clone o repositório
git clone https://github.com/ghibhs/star_dream.git

# 4. Entre na pasta do projeto
cd star_dream/godot_projects/test_v02
```

#### Opção 2: Download Direto (ZIP)

```bash
# 1. Acesse: https://github.com/ghibhs/star_dream

# 2. Clique no botão verde "Code"

# 3. Selecione "Download ZIP"

# 4. Extraia o arquivo ZIP em uma pasta de sua escolha

# 5. Navegue até: star_dream-main/godot_projects/test_v02
```

### ▶️ Como Executar

1. **Abra o Godot Engine**

2. **Importe o Projeto**:
   - Clique em "Import"
   - Navegue até a pasta `star_dream/godot_projects/test_v02`
   - Selecione o arquivo `project.godot`
   - Clique em "Import & Edit"

3. **Execute o Jogo**:
   - Pressione **F5** ou clique no botão ▶️ no canto superior direito
   - Ou: Menu → Project → Run Project

### 🎮 Controles do Jogo

#### Movimento
- **W/A/S/D** ou **Setas**: Movimentação
- **SHIFT**: Dash
- **Mouse**: Rotação do personagem

#### Combate
- **Botão Esquerdo (Click)**: Ataque corpo a corpo
- **Botão Direito (Click)**: Lançar magia
- **Botão Direito (Hold)**: Manter Ice Bolt ativo
- **Q/E**: Trocar magia equipada

#### Interface
- **1-9**: Usar item da hotbar
- **TAB**: Abrir/Fechar inventário
- **ESC**: Pausar jogo

### 🐛 Solução de Problemas

#### "Versão do Godot incompatível"
- **Solução**: Baixe o Godot 4.5+ (dev4 ou superior)
- Link: https://godotengine.org/download/preview

#### "Recursos não encontrados"
- **Solução**: Verifique se você está abrindo a pasta `test_v02` (não a raiz do repositório)
- Caminho correto: `star_dream/godot_projects/test_v02/project.godot`

#### "Erros de importação"
- **Solução**: 
  1. Feche o Godot
  2. Delete a pasta `.godot` dentro de `test_v02`
  3. Abra o projeto novamente
  4. Aguarde a reimportação dos assets

#### "Branch errada no Git"
- **Solução**: O projeto está no branch `thirdversion`
```bash
git checkout thirdversion
```

---

## 📂 Organização de Pastas

```
test_v02/
├── 📁 art/                      # Sprites, texturas e recursos visuais
│   ├── 📁 characters/          # Sprites de personagens
│   │   ├── player/             # Liron (personagem principal)
│   │   └── enemies/            # Lobos, golems, goblins
│   ├── 📁 weapons/             # Arcos, espadas, flechas
│   ├── 📁 environment/         # Árvores, mesas, cenário
│   └── 📁 ui/                  # Ícones, moedas, interface
│
├── 📁 resources/                # Resources (.tres) e classes base
│   ├── 📁 classes/             # Classes de dados (Resources)
│   │   ├── EnemyData.gd        # Classe base para dados de inimigos
│   │   ├── ItemData.gd         # Classe base para dados de items
│   │   └── WeaponData.gd       # Classe base para dados de armas
│   ├── 📁 enemies/             # Recursos de inimigos específicos
│   │   ├── wolf_fast.tres      # Lobo veloz
│   │   ├── wolf_normal.tres    # Lobo normal
│   │   ├── wolf_tank.tres      # Lobo tanque
│   │   ├── goblin_basic.tres   # Goblin básico
│   │   └── golem_tank.tres     # Golem tanque
│   └── 📁 weapons/             # Recursos de armas específicas
│       ├── bow.tres            # Arco
│       └── sword.tres          # Espada
│
├── 📁 scripts/                  # Scripts GDScript organizados
│   ├── 📁 player/              # Scripts do jogador
│   │   ├── player.gd           # Controle do player
│   │   └── player.gd.uid       # ID único do Godot
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
│   ├── 📁 game/                # Scripts gerais do jogo
│   │   ├── the_game.gd         # Gerenciamento da cena principal
│   │   ├── game_stats.gd       # Estatísticas globais (Autoload)
│   │   └── *.gd.uid
│   │
│   ├── 📁 components/          # Componentes reutilizáveis (NOVO!)
│   │   ├── HealthComponent.gd  # Sistema de saúde compartilhado
│   │   └── HitboxComponent.gd  # Sistema de hitbox/ataque
│   │
│   └── 📁 utils/               # Utilitários (NOVO!)
│       └── DebugLog.gd         # Sistema de logging configurável
│
├── 📁 scenes/                   # Cenas .tscn organizadas
│   ├── 📁 player/              # Cenas do jogador
│   │   └── player.tscn         # Cena do personagem principal
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
│   ├── REFACTORING_REPORT.md   # Relatório de refatoração (NOVO!)
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
├── 📁 dev/                      # Arquivos de desenvolvimento (NOVO!)
│   ├── 📁 aseprite/            # Arquivos .aseprite de edição
│   └── 📁 screenshots/         # Capturas de tela e testes
│
├── 📁 .godot/                   # Cache e arquivos do Godot (gerado automaticamente)
├── 📁 .vscode/                  # Configurações do VS Code
│
├── project.godot                # Arquivo principal do projeto Godot
├── icon.svg                     # Ícone do projeto
├── cleanup_duplicates.bat       # Script de limpeza (NOVO!)
├── organize_assets.bat          # Script para organizar assets (NOVO!)
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
- **PascalCase**: `EnemyData`, `WeaponData`, `ItemData`
- **Sem underscores**: Classes seguem padrão Godot puro

## 🔍 Localização Rápida

### Quer modificar...

**Movimento do jogador?**
→ `scripts/player/player.gd`

**IA do inimigo?**
→ `scripts/enemy/enemy.gd`

**Menu principal?**
→ `scripts/ui/main_menu.gd` + `scenes/ui/main_menu.tscn`

**Stats de um inimigo?**
→ `resources/enemies/wolf_fast.tres`

**Stats de uma arma?**
→ `resources/weapons/bow.tres`

**Criar novo componente?**
→ `scripts/components/` (HealthComponent, HitboxComponent)

**Sistema de debug?**
→ `scripts/utils/DebugLog.gd`

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

- ✅ **REFATORAÇÃO COMPLETA** (20/10/2025)
  - Arquivos duplicados removidos
  - Player renomeado (entidades → player)
  - Resources reorganizados (resources/classes, resources/enemies, resources/weapons)
  - Nomenclatura padronizada (EnemyData, WeaponData)
  - Sistema de debug criado (DebugLog)
  - Componentes reutilizáveis (HealthComponent, HitboxComponent)
  - Assets organizados em subpastas
  - **📖 Ver:** `docs/REFACTORING_REPORT.md`
- ✅ Sistema de empurrão implementado
- ✅ Menu system completo
- ✅ Correção de bugs de colisão

## 📞 Referência Rápida de Pastas

| Scripts | `scripts/` | Todos os arquivos .gd |
| Cenas | `scenes/` | Todos os arquivos .tscn |
| Docs | `docs/` | Toda documentação .md |
| Assets | `art/` | Sprites e texturas (organizados em subpastas) |
| Resources | `resources/` | Classes base e instâncias .tres |
| Components | `scripts/components/` | Componentes reutilizáveis |
| Utils | `scripts/utils/` | Utilitários e helpers |
| Dev | `dev/` | Arquivos de desenvolvimento (.aseprite, screenshots) |

---

**Última atualização**: Refatoração completa do projeto  
**Versão**: test_v02 (thirdversion)  
**Data**: 20 de Outubro de 2025

**📖 Leia o relatório completo:** `docs/REFACTORING_REPORT.md`

---

## 🌐 Deploy e Documentação

### 📦 Deploy Web (Godot 4.x)

O jogo foi desenvolvido em Godot 4.5, que possui suporte experimental para Web (HTML5). Para gerar o build web:

1. **No Godot**: Menu → Project → Export
2. Selecione **Web** como plataforma
3. Configure os templates de exportação (se necessário)
4. Exporte para uma pasta `build/web`

**Opções de Hospedagem Gratuita:**
- **Itch.io**: https://itch.io (recomendado para jogos Godot)
- **GitHub Pages**: https://pages.github.com
- **Vercel**: https://vercel.com (requer configuração adicional)
- **Netlify**: https://netlify.com

> ⚠️ **Nota**: Godot 4.x web ainda é experimental. Para melhor compatibilidade, considere build desktop.

### 📚 Documentação Completa

- **GAME_FEATURES.md**: Documentação completa de todas as funcionalidades
- **docs/REFACTORING_REPORT.md**: Relatório de refatoração do código
- **docs/ENEMY_SYSTEM_README.md**: Sistema de inimigos detalhado
- **docs/COLLISION_SETUP.md**: Sistema de colisão
- **docs/SISTEMA_EMPURRAO.md**: Mecânica de empurrão

### 📊 Relatório Final

**Aprendizados:**
- Arquitetura de jogos com Godot Engine
- Sistema de estados (State Machine) para IA de inimigos
- Gerenciamento de recursos com Resources (.tres)
- Sistema de camadas de colisão para diferentes interações
- Refatoração de código para melhor manutenibilidade

**Melhorias Implementadas:**
- ✅ Sistema de magias com cooldown
- ✅ Ice Beam como raio laser contínuo com slow
- ✅ Sistema de stun opcional no dano
- ✅ Organização completa de assets e scripts
- ✅ Documentação abrangente de todos os sistemas
- ✅ Sistema de componentes reutilizáveis

**Próximos Passos:**
- [ ] Sistema de experiência e level up
- [ ] Mais tipos de inimigos e bosses
- [ ] Sistema de quests
- [ ] Save/Load game
- [ ] Efeitos sonoros e música
- [ ] Partículas e efeitos visuais melhorados
- [ ] Sistema de crafting
- [ ] Multiplayer co-op (futuro distante)

---

## 📞 Contato e Suporte

**Repositório GitHub**: https://github.com/ghibhs/star_dream  
**Branch do Projeto**: `thirdversion`

Para dúvidas ou sugestões, abra uma issue no GitHub ou entre em contato com a equipe.

---

**Desenvolvido com ❤️ usando Godot Engine 4.5**
