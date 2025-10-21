# Sistema de Knockback (Empurrão ao Receber Dano)

## 🎯 Funcionalidade

Quando o player é atacado por um inimigo, ele agora sofre um **empurrão (knockback)** na direção **oposta** ao atacante, criando um feedback tátil e visual do impacto.

## 🎮 Como Funciona

### Visual do Efeito:
```
        Inimigo
           👹
            ↓ [ATAQUE]
          
          Player
            😫
         ←←←← [EMPURRADO]
```

### Mecânica:
1. Inimigo ataca o player
2. Player recebe dano
3. **Direção do empurrão** é calculada: `(posição_player - posição_inimigo).normalized()`
4. Player é empurrado por **0.2 segundos** (configurável)
5. Durante o empurrão, player **perde controle temporariamente**
6. Após o empurrão, controle volta ao normal

## ⚙️ Propriedades Configuráveis

No script do player (`player.gd`), você pode ajustar:

```gdscript
@export var knockback_force: float = 300.0      # Força do empurrão
@export var knockback_duration: float = 0.2     # Duração em segundos
```

### Valores Recomendados:

| Estilo | Force | Duration | Sensação |
|--------|-------|----------|----------|
| Suave | 200.0 | 0.15s | Nudge leve |
| Normal | 300.0 | 0.2s | Empurrão padrão |
| Forte | 500.0 | 0.3s | Impacto pesado |
| Muito Forte | 800.0 | 0.5s | Voa longe! |

## 🔧 Implementação Técnica

### 1. **Variáveis Adicionadas**

```gdscript
# SISTEMA DE KNOCKBACK (EMPURRÃO)
@export var knockback_force: float = 300.0
@export var knockback_duration: float = 0.2
var is_being_knocked_back: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0
```

### 2. **Prioridade de Movimento**

No `_physics_process()`, o knockback tem **prioridade máxima**:

```gdscript
var final_velocity: Vector2

if is_being_knocked_back:
    # 🥇 Prioridade 1: Knockback (sem controle do player)
    final_velocity = knockback_velocity
elif is_dashing:
    # 🥈 Prioridade 2: Dash
    final_velocity = dash_direction * dash_speed
else:
    # 🥉 Prioridade 3: Movimento normal
    final_velocity = direction * current_speed
```

### 3. **Aplicação do Knockback**

Quando o player recebe dano:

```gdscript
func take_damage(amount: float, attacker_position: Vector2 = Vector2.ZERO) -> void:
    # ... aplica dano ...
    
    # Aplica knockback se temos a posição do atacante
    if attacker_position != Vector2.ZERO:
        apply_knockback(attacker_position)
```

### 4. **Cálculo da Direção**

```gdscript
func apply_knockback(from_position: Vector2) -> void:
    # Calcula direção do empurrão (do atacante para o player)
    var knockback_direction = (global_position - from_position).normalized()
    
    # Define velocidade
    knockback_velocity = knockback_direction * knockback_force
    
    # Ativa estado
    is_being_knocked_back = true
    knockback_timer = knockback_duration
```

### 5. **Timer Automático**

O knockback termina automaticamente após a duração:

```gdscript
func update_knockback_timer(delta: float) -> void:
    if is_being_knocked_back:
        knockback_timer -= delta
        if knockback_timer <= 0.0:
            end_knockback()
```

## 📊 Exemplo de Sequência

### Cenário: Player é Atacado

```
Frame 1: Inimigo ataca
         [ENEMY] 💥 Player detectado na hitbox ATIVA!
         [ENEMY] ✅ Dano 15.0 aplicado ao player (com knockback)!

Frame 2: take_damage() chamado
         [PLAYER] 💔 DANO RECEBIDO: 15.0
         [PLAYER]    HP: 100.0 → 85.0 (85.0%)
         [PLAYER]    💥 Knockback aplicado!
         [PLAYER]       Direção: (-0.8, 0.2)
         [PLAYER]       Força: 300.0
         
Frame 3-12: (0.2s a 60fps)
         Player está sendo empurrado
         is_being_knocked_back = true
         velocity = knockback_velocity
         Player NÃO responde a input de movimento
         
Frame 13: Knockback termina
         is_being_knocked_back = false
         Player recupera controle total
```

## 🎨 Interação com Outros Sistemas

### 1. **Knockback vs Dash**

Knockback **cancela** dash:
```gdscript
if is_being_knocked_back:
    final_velocity = knockback_velocity  # Ignora tudo!
elif is_dashing:
    final_velocity = dash_direction * dash_speed
```

**Cenário:** Player dashando → Recebe dano → Dash cancelado, knockback aplicado

### 2. **Knockback vs Animação**

Animações param durante knockback:
```gdscript
if direction != Vector2.ZERO and not is_dashing and not is_being_knocked_back:
    play_animations(direction)
else:
    animation.stop()
```

### 3. **Knockback vs Morte**

Se o dano matar o player, knockback **não é aplicado**:
```gdscript
if current_health <= 0:
    die()
    return  # ← Sai antes de aplicar knockback

# Aplica knockback (só se sobreviveu)
if attacker_position != Vector2.ZERO:
    apply_knockback(attacker_position)
```

## 💡 Casos de Uso

### Gameplay Emergente

**1. Empurrado para parede:**
- Player encostado na parede
- Inimigo ataca
- Knockback empurra player → **colide com parede** → não se move muito
- Resultado: Player fica "encurralado"

**2. Empurrado para grupo de inimigos:**
- Player entre 2 inimigos
- Inimigo A ataca → empurra para direita
- Player cai na frente do Inimigo B!
- Resultado: Situação perigosa

**3. Empurrado para segurança:**
- Player cercado
- Inimigo ataca pela frente
- Knockback empurra para trás → **fora do círculo de inimigos**
- Resultado: Knockback ajudou!

## 🔧 Ajustes e Balanceamento

### Para Inimigos Diferentes

Você pode fazer o knockback variar por tipo de inimigo:

```gdscript
# No EnemyData.tres
@export var knockback_multiplier: float = 1.0

# No enemy.gd ao aplicar dano:
body.take_damage(enemy_data.damage, global_position)
# Depois adicione no player:
# knockback_force * enemy.knockback_multiplier
```

**Exemplos:**
- Lobo pequeno: `0.8x` (empurrão fraco)
- Lobo normal: `1.0x` (padrão)
- Urso: `1.5x` (empurrão forte!)
- Boss gigante: `2.5x` (jogador voa!)

### Para Combate Tático

**Reduz knockback se estiver bloqueando:**
```gdscript
if is_blocking:
    apply_knockback(attacker_position)
    knockback_velocity *= 0.3  # 70% de redução
```

**Cancela knockback com dash:**
```gdscript
if Input.is_action_just_pressed("dash") and is_being_knocked_back:
    end_knockback()
    start_dash()
    # Player usa dash para "recuperar" do knockback!
```

## 🧪 Testando

### Teste 1: Knockback Básico
1. Aproxime de um inimigo
2. Deixe ele atacar você
3. ✅ Você deve ser empurrado para trás
4. ✅ Deve perder controle por ~0.2s
5. ✅ Console mostra: "💥 Knockback aplicado!"

### Teste 2: Direção do Knockback
1. Posicione inimigo à sua **direita**
2. Deixe atacar
3. ✅ Você é empurrado para **esquerda**

### Teste 3: Knockback + Parede
1. Encoste numa parede
2. Inimigo ataca
3. ✅ Knockback é aplicado mas movimento é limitado pela colisão

### Teste 4: Knockback + Morte
1. Fique com pouco HP (< 15)
2. Deixe inimigo atacar com dano letal
3. ✅ Você morre **sem** knockback (die() retorna antes)

## 📝 Arquivos Modificados

### `scripts/player/player.gd`
- **Adicionadas variáveis:**
  - `knockback_force`, `knockback_duration`
  - `is_being_knocked_back`, `knockback_velocity`, `knockback_timer`
  
- **Modificado `_physics_process()`:**
  - Adicionada chamada `update_knockback_timer(delta)`
  - Knockback tem prioridade no cálculo de `final_velocity`
  
- **Novas funções:**
  - `update_knockback_timer(delta)` - Atualiza timer
  - `apply_knockback(from_position)` - Aplica empurrão
  - `end_knockback()` - Finaliza empurrão
  
- **Modificado `take_damage()`:**
  - Agora aceita parâmetro `attacker_position`
  - Chama `apply_knockback()` se sobreviver

### `scripts/enemy/enemy.gd`
- **Modificado `_on_hitbox_body_entered()`:**
  - Passa `global_position` ao chamar `take_damage()`

## 🎯 Resultado Final

Agora o combate tem muito mais **peso** e **feedback**:

```
Antes (sem knockback):
👹→😐 (Player leva dano mas fica parado)

Depois (com knockback):
👹→💥😫←← (Player é empurrado, dá sensação de impacto!)
```

### Console Output:
```
[ENEMY]    💥 Player detectado na hitbox ATIVA!
[ENEMY]    ✅ Dano 15.0 aplicado ao player (com knockback)!
[PLAYER] 💔 DANO RECEBIDO: 15.0
[PLAYER]    HP: 100.0 → 85.0 (85.0%)
[PLAYER]    💥 Knockback aplicado!
[PLAYER]       Direção: (-0.8944, 0.4472)
[PLAYER]       Força: 300.0
```

**Combate agora tem impacto visual e tátil!** 💥🎮✨

---

## 🚀 Melhorias Futuras

### 1. **Partículas no Impacto**
```gdscript
func apply_knockback(from_position: Vector2) -> void:
    # ... código existente ...
    
    # Spawna partículas de impacto
    var particles = impact_particles_scene.instantiate()
    particles.global_position = global_position
    get_parent().add_child(particles)
```

### 2. **Screen Shake**
```gdscript
func apply_knockback(from_position: Vector2) -> void:
    # ... código existente ...
    
    # Chacoalha a câmera
    if has_node("/root/Camera"):
        get_node("/root/Camera").shake(0.1, 5.0)
```

### 3. **Som de Impacto**
```gdscript
func apply_knockback(from_position: Vector2) -> void:
    # ... código existente ...
    
    # Toca som
    $ImpactSound.play()
```

### 4. **Slow Motion no Impacto**
```gdscript
func apply_knockback(from_position: Vector2) -> void:
    # ... código existente ...
    
    # Slow motion breve
    Engine.time_scale = 0.3
    await get_tree().create_timer(0.05).timeout
    Engine.time_scale = 1.0
```
