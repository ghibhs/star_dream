# Sistema de Empurrão de Inimigos

## 📋 Visão Geral

Sistema que permite ao jogador empurrar inimigos mais fracos enquanto caminha, mas ser bloqueado por inimigos mais fortes. Isso evita que o jogador fique travado ao colidir com inimigos.

## ⚙️ Como Funciona

### Propriedades

**Jogador (`entidades.gd`):**
- `player_push_strength: float = 100.0` - Força de empurrão do jogador

**Inimigo (`EnemyData.gd`):**
- `push_force: float = 50.0` - Resistência ao empurrão
  - **0**: Não pode ser empurrado (inimigo muito forte/pesado)
  - **1-50**: Difícil de empurrar (inimigos fortes)
  - **51-99**: Fácil de empurrar (inimigos fracos)
  - **100+**: Muito fácil de empurrar (inimigos muito fracos)

### Mecânica

```
SE player_push_strength > enemy_push_force:
    Empurra o inimigo
SENÃO:
    Jogador é bloqueado
```

**Força de empurrão calculada:**
```gdscript
push_power = (player_push_strength - enemy_push_resistance) * 0.5
```

## 🎮 Exemplos de Configuração

### Lobo Comum (Empurrável)
```gdscript
push_force = 60.0  # Jogador (100) > Lobo (60) = É empurrado
```

### Boss/Golem (Imóvel)
```gdscript
push_force = 0.0  # Jogador (100) < Boss (0) = Não é empurrado (bloqueia)
```

### Goblin Fraco (Muito Empurrável)
```gdscript
push_force = 120.0  # Jogador (100) < Goblin (120) = Facilmente empurrado
```

### Cavaleiro Pesado (Difícil de Empurrar)
```gdscript
push_force = 30.0  # Jogador (100) > Cavaleiro (30) = Empurrado com dificuldade
```

## 📝 Implementação

### 1. Arquivos Modificados

#### `data_gd/EnemyData.gd`
```gdscript
@export var push_force: float = 50.0  # Nova propriedade
```

#### `entidades.gd` (Player)
```gdscript
@export var player_push_strength: float = 100.0

func handle_enemy_push() -> void:
    for i in range(get_slide_collision_count()):
        var collision = get_slide_collision(i)
        var collider = collision.get_collider()
        
        if collider and collider.is_in_group("enemies"):
            if player_push_strength > collider.get_push_force():
                var push_direction = (collider.global_position - global_position).normalized()
                var push_power = (player_push_strength - collider.get_push_force()) * 0.5
                collider.apply_push(push_direction, push_power)
```

#### `enemy.gd`
```gdscript
var push_velocity: Vector2 = Vector2.ZERO
var push_decay: float = 5.0

func get_push_force() -> float:
    return enemy_data.push_force if enemy_data else 0.0

func apply_push(push_direction: Vector2, push_power: float) -> void:
    push_velocity = push_direction * push_power

func _physics_process(delta: float):
    # Aplica e decai o empurrão
    if push_velocity.length() > 0.1:
        velocity += push_velocity
        push_velocity = push_velocity.lerp(Vector2.ZERO, push_decay * delta)
```

### 2. Configurar Inimigos

No Godot Editor, ao criar um novo `Enemy_Data`:

1. Clique com botão direito em `EnemyData/` → **New Resource** → **Enemy_Data**
2. Configure as propriedades:
   - **Enemy Name**: Nome do inimigo
   - **Push Force**: Configure conforme a força desejada
     - Boss: 0
     - Forte: 20-40
     - Normal: 50-70
     - Fraco: 80-100+

## 🧪 Testando

1. Execute o jogo
2. Ande em direção ao lobo
3. **Comportamento esperado:**
   - ✅ Lobo é empurrado suavemente
   - ✅ Jogador não fica travado
   - ✅ Console mostra: `[ENEMY] 💨 Empurrado! Direção: ... Força: ...`

4. Se criar um inimigo com `push_force = 0.0`:
   - ✅ Jogador é bloqueado (não consegue passar)
   - ✅ Inimigo não se move

## 🎯 Benefícios

- ✅ **Evita travamento**: Jogador nunca fica preso contra inimigos fracos
- ✅ **Diferenciação**: Inimigos fortes/bosses bloqueiam o caminho
- ✅ **Feedback tátil**: Sistema de peso/força intuitivo
- ✅ **Balanceamento**: Ajustável por inimigo individualmente
- ✅ **Suave**: Decaimento gradual do empurrão (não é instantâneo)

## 🔧 Ajustes Finos

### Aumentar força do jogador
```gdscript
# entidades.gd
@export var player_push_strength: float = 150.0  # Empurra inimigos mais fortes
```

### Fazer empurrão mais rápido
```gdscript
# enemy.gd
var push_decay: float = 10.0  # Decai mais rápido (era 5.0)
```

### Fazer empurrão mais forte
```gdscript
# entidades.gd - na função handle_enemy_push
var push_power = (player_push_strength - enemy_push_resistance) * 1.0  # Era 0.5
```

## 📊 Valores Recomendados

| Tipo de Inimigo | push_force | Comportamento |
|-----------------|------------|---------------|
| Slime           | 150        | Muito fácil de empurrar |
| Goblin          | 100        | Fácil de empurrar |
| Lobo            | 60         | Empurrável |
| Orc             | 40         | Difícil de empurrar |
| Cavaleiro       | 20         | Muito difícil |
| Golem/Boss      | 0          | Imóvel (bloqueia) |

