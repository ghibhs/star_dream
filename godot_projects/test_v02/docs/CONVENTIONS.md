# 📏 Convenções e Padrões do Projeto

## 📛 Nomenclatura

### Arquivos e Pastas

```
✅ CORRETO                    ❌ EVITAR
snake_case.gd                PascalCase.gd
enemy_system.md              enemySystem.md
main_menu.tscn               MainMenu.tscn
player/                      Player/
```

**Regra**: `snake_case` (minúsculas com underscore)

### Classes GDScript

```gdscript
# ✅ CORRETO
class_name Enemy_Data
class_name Weapon_Data
class_name Item_Data

# ❌ EVITAR
class_name enemyData
class_name WeaponData
```

**Regra**: `PascalCase` com underscore antes de "Data"

### Variáveis e Funções

```gdscript
# ✅ CORRETO
var player_health: float
var current_state: State
func calculate_damage() -> float:
func _on_button_pressed() -> void:

# ❌ EVITAR
var playerHealth: float
var CurrentState: State
func CalculateDamage() -> float:
```

**Regra**: `snake_case` para tudo, exceto classes

### Constantes

```gdscript
# ✅ CORRETO
const MAX_HEALTH: float = 100.0
const ATTACK_RANGE: float = 30.0

# ❌ EVITAR
const maxHealth: float = 100.0
const attack_range: float = 30.0
```

**Regra**: `SCREAMING_SNAKE_CASE`

### Enums

```gdscript
# ✅ CORRETO
enum State { IDLE, CHASE, ATTACK, HURT, DEAD }
enum Direction { UP, DOWN, LEFT, RIGHT }

# ❌ EVITAR
enum state { idle, chase, attack }
enum Direction { up, down, left, right }
```

**Regra**: Nome em `PascalCase`, valores em `SCREAMING_SNAKE_CASE`

## 📁 Organização de Arquivos

### Estrutura Obrigatória

```
scripts/
├── player/          # Tudo relacionado ao jogador
├── enemy/           # Tudo relacionado a inimigos
├── items/           # Items coletáveis
├── projectiles/     # Projéteis e munição
├── ui/              # Menus e interface
└── game/            # Gerenciamento geral

scenes/
├── [mesma estrutura que scripts/]

docs/
├── [todos os .md aqui]
```

### Correspondência Script ↔ Cena

```
✅ CORRETO
scripts/enemy/enemy.gd
scenes/enemy/enemy.tscn

scripts/player/entidades.gd
scenes/player/entidades.tscn

❌ EVITAR
scripts/enemy/enemy.gd
scenes/enemies/enemy_scene.tscn  # Nome diferente ou pasta diferente
```

**Regra**: Script e cena devem ter o mesmo nome base e estar em pastas correspondentes

## 🎨 Padrões de Código

### Estrutura de um Script

```gdscript
extends CharacterBody2D  # 1. Herança

# 2. Documentação (opcional mas recomendado)
## Descrição breve do que o script faz

# 3. Constantes
const MAX_SPEED: float = 200.0

# 4. @export (variáveis editáveis no editor)
@export var health: float = 100.0
@export var damage: float = 10.0

# 5. Variáveis públicas (sem @export)
var current_state: State = State.IDLE

# 6. @onready (referências a nós)
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

# 7. Enums e tipos internos
enum State { IDLE, MOVING, ATTACKING }

# 8. Funções built-in (ordem específica)
func _ready() -> void:
    pass

func _process(delta: float) -> void:
    pass

func _physics_process(delta: float) -> void:
    pass

func _input(event: InputEvent) -> void:
    pass

# 9. Funções públicas
func take_damage(amount: float) -> void:
    pass

# 10. Funções privadas
func _calculate_damage() -> float:
    pass

# 11. Signals handlers (por último)
func _on_timer_timeout() -> void:
    pass
```

### Tipagem Forte

```gdscript
# ✅ CORRETO - Sempre use tipos
var health: float = 100.0
var target: Node2D = null
func get_damage() -> float:
    return damage

# ❌ EVITAR - Sem tipos
var health = 100.0
var target = null
func get_damage():
    return damage
```

### Comentários e Debug

```gdscript
# ✅ CORRETO
# Verifica se o player está no range de ataque
if distance < attack_range:
    print("[ENEMY] Player dentro do range: %.1f" % distance)
    perform_attack()

# ❌ EVITAR
if distance < attack_range:  # attack
    print("attack")  # Generic comment
```

**Regra**: Comentários descritivos, prints com prefixo `[CONTEXTO]`

## 🎯 Sistema de Colisão

### Convenção de Camadas

```gdscript
# Sempre use números decimais, não binários
collision_layer = 2   # ✅ Player layer
collision_mask = 13   # ✅ Detecta 1(World) + 4(Enemy) + 8(Enemy Hitbox)

# Evite hard-coding, use constantes se possível
const LAYER_PLAYER: int = 2
const LAYER_ENEMY: int = 4
const MASK_DETECT_ENEMIES: int = 4 + 8  # Enemy + Enemy Hitbox
```

### Nomeação de Áreas

```
✅ CORRETO                    ❌ EVITAR
DetectionArea2D              Area2D
HitboxArea2D                 Area2D2
AttackArea2D                 DamageArea
```

## 📦 Resources (.tres)

### Estrutura de Pasta

```
data_gd/              # Classes base (Enemy_Data, Item_Data, etc)
EnemyData/            # Instâncias de Enemy_Data
ItemData/             # Instâncias de Item_Data
WeaponData/           # Instâncias de Weapon_Data (se existir)
```

### Nomenclatura de Resources

```
✅ CORRETO
wolf_fast.tres        # Descrição + característica
goblin_weak.tres
sword_iron.tres

❌ EVITAR
wolf.tres            # Muito genérico
FastWolf.tres        # PascalCase
wolf1.tres           # Números sem significado
```

## 🎬 Cenas (.tscn)

### Root Node

```
✅ CORRETO
Enemy (CharacterBody2D)      # Tipo do nó corresponde à função
Player (CharacterBody2D)
Projectile (Area2D)

❌ EVITAR
Node2D                       # Muito genérico
EnemyCharacter              # Redundante
```

### Hierarquia Padrão

```
Enemy (CharacterBody2D)
├── AnimatedSprite2D         # Visual
├── CollisionShape2D         # Física do corpo
├── DetectionArea2D          # Detecção
│   └── CollisionShape2D
├── HitboxArea2D             # Dano
│   └── CollisionShape2D
└── Timers/                  # Timers agrupados (opcional)
    ├── AttackTimer
    └── HitFlashTimer
```

## 📝 Documentação

### Arquivos .md

```
✅ CORRETO
ENEMY_SYSTEM_README.md       # Descrição clara
BUG_FIX_COLLISION_LAYERS.md  # Tipo + contexto
QUICK_START_ENEMIES.md       # Ação + alvo

❌ EVITAR
enemies.md                   # Muito vago
fix.md                       # Sem contexto
README.md (múltiplos)        # Confuso
```

### Estrutura de Documento

```markdown
# 📋 Título com Emoji

## Seção Principal

### Subseção

- Lista
- De
- Items

```gdscript
# Código com syntax highlighting
```

> ⚠️ Avisos importantes em blockquote com emoji

📖 Referências com emoji
```

## 🚫 O Que Evitar

### ❌ Caminhos Absolutos

```gdscript
# ❌ EVITAR
var scene = load("C:/Users/user/project/enemy.tscn")

# ✅ CORRETO
var scene = load("res://scenes/enemy/enemy.tscn")
```

### ❌ Magic Numbers

```gdscript
# ❌ EVITAR
if distance < 300:
    collision_layer = 4

# ✅ CORRETO
const CHASE_RANGE: float = 300.0
const LAYER_ENEMY: int = 4

if distance < CHASE_RANGE:
    collision_layer = LAYER_ENEMY
```

### ❌ Código Morto

```gdscript
# ❌ EVITAR - Deletar, não comentar
#func old_function():
#    pass

# ✅ CORRETO - Git guarda o histórico
```

### ❌ Prints sem Contexto

```gdscript
# ❌ EVITAR
print("started")
print(health)
print("done")

# ✅ CORRETO
print("[ENEMY] Combat started")
print("[ENEMY] Health: %.1f/%.1f" % [current_health, max_health])
print("[ENEMY] Attack sequence completed")
```

## ✅ Checklist para Novos Arquivos

### Novo Script (.gd)

- [ ] Nome em snake_case
- [ ] Pasta correta em `scripts/`
- [ ] Tipagem forte em todas as variáveis
- [ ] Comentários descritivos
- [ ] Prints com prefixo `[CONTEXTO]`
- [ ] Funções organizadas por seção

### Nova Cena (.tscn)

- [ ] Nome corresponde ao script
- [ ] Pasta correta em `scenes/`
- [ ] Root node com tipo apropriado
- [ ] Collision layers corretas
- [ ] Script atribuído

### Novo Resource (.tres)

- [ ] Nome descritivo
- [ ] Pasta correta em `*Data/`
- [ ] Todas as propriedades preenchidas
- [ ] Valores balanceados

### Nova Documentação (.md)

- [ ] Nome descritivo em SCREAMING_SNAKE_CASE
- [ ] Localizada em `docs/`
- [ ] Adicionada ao `docs/INDEX.md`
- [ ] Emojis para melhor visualização
- [ ] Code blocks com syntax highlighting

## 🔄 Atualizando Este Documento

Se você adicionar novas convenções:

1. Adicione aqui
2. Atualize exemplos existentes se necessário
3. Comunique a equipe
4. Faça commit com mensagem clara

---

**Última Atualização**: Organização completa do projeto
**Versão**: 1.0
**Mantenha este documento atualizado!** 📝
