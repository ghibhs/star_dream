# Sistema de Boss

## Visão Geral

O sistema de boss foi criado para inimigos especiais com mecânicas diferenciadas:

- **Sempre sabe onde está o player** (não precisa de detecção)
- **Área de ataque travada** durante animação
- **Animações especiais** para caminhada e ataque
- **Mais resistente** a efeitos de status (50% de duração de stun)
- **Barra de vida maior** e mais visível

## Arquivos

### Script Principal
- **Localização**: `scripts/enemy/boss.gd`
- **Herda de**: `CharacterBody2D`
- **Usa**: `EnemyData.gd` (mesmo resource dos inimigos normais)

### Cena Base
- **Localização**: `scenes/enemy/boss.tscn`
- **Nodes**:
  - `AnimatedSprite2D` - Sprite com animações
  - `CollisionShape2D` - Colisão do corpo
  - `AttackArea2D` - Área de ataque (ativa apenas durante golpe)
  - `AttackTimer` - Cooldown entre ataques
  - `HitFlashTimer` - Flash de dano

### Dados Exemplo
- **Localização**: `resources/enemies/boss_demon.tres`
- **Stats**: 500 HP, 30 dmg, 15 def
- **Velocidade**: 70 px/s
- **Attack Range**: 80 pixels
- **Cooldown**: 3 segundos

## Estados do Boss

### 1. IDLE
- Boss parado, esperando
- Toca animação "idle" (ou "walk" parada)
- Sempre busca o player

### 2. WALK
- Boss caminha em direção ao player
- **Animação**: "walk"
- **Movimento**: Contínuo, sempre seguindo o player
- Entra em ATTACK quando está no alcance

### 3. ATTACK
- Boss **trava sua posição** no chão
- **Fase 1 - Aviso** (0.5s padrão):
  - Toca animação "attack"
  - Área de ataque fica **visível mas NÃO causa dano**
  - Player pode ver e esquivar
  
- **Fase 2 - Execução** (0.25s padrão):
  - Área de ataque é **ATIVADA**
  - Causa dano se player estiver dentro
  
- **Fase 3 - Recovery**:
  - Área desativada
  - Inicia cooldown
  - Volta para WALK

### 4. HURT
- Boss recebe dano mas **não é stunado facilmente**
- Apenas mostra flash vermelho
- Continua atacando/perseguindo

### 5. DEAD
- Boss derrotado
- Toca animação de morte
- Pode emitir sinal de vitória

## Diferenças do Enemy Normal

| Característica | Enemy Normal | Boss |
|----------------|--------------|------|
| Detecção | Precisa de DetectionArea | Sempre sabe onde está o player |
| Movimento no Ataque | Continua se movendo | **TRAVA a posição** |
| Área de Ataque | Sempre visível | Só ativa durante golpe |
| Fases de Ataque | Ataque direto | **3 fases** (aviso, execução, recovery) |
| Resistência a Stun | Normal | **50% de duração** |
| Barra de Vida | 50x6 pixels | **100x10 pixels** |
| Estado após Dano | Entra em HURT | **Continua atacando** |

## Sistema de Ataque Detalhado

### Configuração no .tres

```gdscript
# Área de ataque
attack_hitbox_shape = RectangleShape2D  # Forma do golpe (60x80 recomendado)
attack_hitbox_offset = Vector2(50, 0)   # Distância à frente do boss

# Timing do ataque
attack_warning_delay = 0.5              # Tempo de aviso (player vê mas não toma dano)
attack_hitbox_duration = 0.25           # Tempo que causa dano
attack_cooldown = 3.0                   # Tempo entre ataques

# Dano
damage = 30.0                           # Dano base
applies_knockback = true                # Empurra o player
knockback_force = 600.0                 # Força do empurrão (maior que inimigos normais)
knockback_duration = 0.4                # Duração do empurrão

# Visual
attack_hitbox_color = Color(1, 0.2, 0, 0.8)  # Cor alaranjada
```

### Funcionamento do Ataque

1. **Boss entra em range** → Estado muda para ATTACK
2. **Boss trava posição** → `velocity = Vector2.ZERO`
3. **Rotaciona área** para o player
4. **Toca animação** "attack"
5. **Aguarda warning_delay** (0.5s) - Player pode esquivar
6. **Ativa área** de ataque por `attack_hitbox_duration` (0.25s)
7. **Desativa área** de ataque
8. **Inicia cooldown** (3.0s)
9. **Volta para WALK**

## Animações Necessárias

O boss precisa de 4 animações no SpriteFrames:

### 1. idle (Opcional)
- Boss parado, respirando
- Loop: true
- Speed: 5.0 fps

### 2. walk (Obrigatório)
- Boss caminhando
- Loop: true
- Speed: 6.0 fps

### 3. attack (Obrigatório)
- Boss executando golpe
- Loop: true (toca durante todo o ataque)
- Speed: 8.0 fps
- **Importante**: Animação deve ter frames que mostrem claramente o movimento do golpe

### 4. death (Opcional)
- Boss morrendo
- Loop: false (toca uma vez)
- Speed: 5.0 fps

Se uma animação não existir:
- `idle` → usa `walk` parada
- `attack` → continua tocando `walk` ou `idle`
- `death` → aguarda 1 segundo e remove

## Como Usar

### 1. Criar Sprites

Crie uma spritesheet com as animações do boss:
```
boss_spritesheet.png
[idle_frame1] [idle_frame2] [idle_frame3]
[walk_frame1] [walk_frame2] [walk_frame3] [walk_frame4]
[attack_frame1] [attack_frame2] [attack_frame3] [attack_frame4] [attack_frame5]
[death_frame1] [death_frame2] [death_frame3] [death_frame4]
```

### 2. Configurar SpriteFrames

No Godot:
1. Crie novo recurso `SpriteFrames`
2. Adicione suas animações:
   - `idle` (opcional)
   - `walk` (obrigatório)
   - `attack` (obrigatório)
   - `death` (opcional)

### 3. Criar Boss Data (.tres)

1. Botão direito em `resources/enemies/`
2. **New Resource** → `EnemyData`
3. Configure as propriedades:

```gdscript
enemy_name = "Seu Boss"
sprite_frames = [seu SpriteFrames]
animation_name = "walk"
sprite_scale = Vector2(2, 2)  # Boss é maior

# Stats
max_health = 500.0
damage = 30.0
defense = 15.0
move_speed = 70.0

# Ranges
chase_range = 500.0  # Não usado mas precisa existir
attack_range = 80.0  # Distância para atacar

# Colisão
collision_shape = CircleShape2D (radius: 24.0)

# Área de Ataque
attack_hitbox_shape = RectangleShape2D (size: 60x80)
attack_hitbox_offset = Vector2(50, 0)
attack_hitbox_duration = 0.25
attack_warning_delay = 0.5
attack_hitbox_color = Color(1, 0.2, 0, 0.8)

# Knockback
applies_knockback = true
knockback_force = 600.0
knockback_duration = 0.4

# Timing
attack_cooldown = 3.0

# Recompensas
experience_drop = 500
coin_drop = 100
```

### 4. Instanciar na Cena

1. Arraste `scenes/enemy/boss.tscn` para sua cena
2. No inspetor, arraste seu `.tres` para `Boss Data`
3. Posicione o boss onde quiser

### 5. Testando

Execute o jogo:
- Boss deve aparecer e **imediatamente** seguir o player
- Ao chegar no range, **para e ataca**
- Durante ataque:
  - **Fase 1**: Área vermelha/alaranjada visível (aviso)
  - **Fase 2**: Área ativa, causa dano se player encostar
  - **Fase 3**: Cooldown, volta a caminhar

## Dicas de Design

### Balanceamento

1. **HP**: Bosses devem ter 5-10x mais vida que inimigos normais
   - Inimigo normal: 50-100 HP
   - Boss: 300-1000 HP

2. **Dano**: Boss deve matar player em 3-5 hits
   - Se player tem 100 HP → Boss faz 20-35 de dano

3. **Attack Range**: Deve ser maior que inimigos normais
   - Inimigo: 30-40 pixels
   - Boss: 60-100 pixels

4. **Warning Delay**: Tempo para jogador reagir
   - Boss rápido: 0.3s
   - Boss normal: 0.5s
   - Boss lento/forte: 0.7s

5. **Attack Cooldown**: Frequência de ataques
   - Boss agressivo: 2.0s
   - Boss normal: 3.0s
   - Boss defensivo: 4.0s

### Animação de Ataque

A animação de ataque deve:
- **Começar devagar** (wind-up) → Aviso visual
- **Acelerar no meio** (golpe) → Momento de dano
- **Terminar devagar** (recovery) → Boss voltando à posição

Exemplo para 8 frames (8 fps):
```
Frame 1-2: Wind-up (preparação)
Frame 3-4: Swing (golpe)
Frame 5-6: Impact (impacto)
Frame 7-8: Recovery (recuperação)
```

Com `attack_warning_delay = 0.5s`, player vê frames 1-4 antes do dano.

### Visual Feedback

1. **Área de Ataque Colorida**:
   - Aviso: Laranja transparente (pode esquivar)
   - Ativa: Vermelho forte (vai causar dano)

2. **Barra de Vida**:
   - Verde → Amarelo → Laranja → Roxo (crítico)

3. **Flash de Dano**:
   - Vermelho intenso (Color(1, 0.3, 0.3))

## Eventos Especiais

### Boss Derrotado

O boss emite sinal para `GameStats` quando morre:

```gdscript
if has_node("/root/GameStats"):
    get_node("/root/GameStats").boss_defeated()
```

Você pode usar isso para:
- Desbloquear porta
- Iniciar cutscene
- Mostrar tela de vitória
- Dropar item especial

### Drop de Recompensas

Implemente `drop_rewards()` customizado:

```gdscript
func drop_rewards() -> void:
    # Exp e moedas padrão
    print("[BOSS] 💰 Dropando: %d exp, %d moedas" % [
        boss_data.experience_drop, 
        boss_data.coin_drop
    ])
    
    # Item especial de boss
    var special_item = preload("res://scenes/items/boss_sword.tscn").instantiate()
    special_item.global_position = global_position
    get_parent().add_child(special_item)
```

## Debugging

### Logs do Boss

O boss imprime logs detalhados:

```
[BOSS] ⚔️ Boss inicializado!
[BOSS] 🎯 Player encontrado: Player
[BOSS] ⚙️ Configurando boss...
[BOSS] Estado: IDLE → WALK
[BOSS] ⚔️ INICIANDO ATAQUE!
[BOSS]    Posição travada em: (x, y)
[BOSS]    🎯 Área de ataque rotacionada: X graus
[BOSS]    ⚠️ Fase de aviso: 0.50s
[BOSS]    ⚡ ÁREA DE ATAQUE ATIVADA!
[BOSS]    🛑 Área de ataque desativada
[BOSS]    ✅ Ataque concluído
```

### Debug Visual

Ative **Debug > Visible Collision Shapes** no Godot para ver:
- Círculo azul: Colisão do corpo do boss
- Retângulo colorido: Área de ataque (rotaciona com boss)

### Problemas Comuns

**Boss não se move**:
- Verifique se `boss_data` está atribuído
- Verifique `move_speed` no .tres
- Veja se player está no grupo "player"

**Boss não ataca**:
- Verifique se `attack_range` está correto
- Veja logs de distância
- Confirme que animação "attack" existe

**Área de ataque não causa dano**:
- Verifique collision layers/masks do `AttackArea2D`
- Layer 8 (enemies), Mask 2 (player)
- Confirme que player tem método `take_damage()`

**Boss stunado demais**:
- Boss tem 50% de resistência a stun
- Para imunidade total, remova `apply_stun()` do script

## Extensões Futuras

### Fases do Boss

Adicione fases baseadas em HP:

```gdscript
func update_health_bar() -> void:
    # ... código existente ...
    
    var health_percent = current_health / boss_data.max_health
    
    # Muda comportamento por fase
    if health_percent < 0.5 and not is_enraged:
        enter_enraged_mode()
    elif health_percent < 0.25 and not is_desperate:
        enter_desperate_mode()

func enter_enraged_mode() -> void:
    is_enraged = true
    boss_data.attack_cooldown = 2.0  # Ataca mais rápido
    boss_data.move_speed *= 1.3      # Move mais rápido
    sprite.modulate = Color(1.2, 0.8, 0.8)  # Vermelho
    print("[BOSS] 💢 ENRAGED MODE!")
```

### Ataques Especiais

Adicione variedade:

```gdscript
var attack_pattern: int = 0

func perform_attack() -> void:
    match attack_pattern:
        0: normal_attack()
        1: area_attack()
        2: charge_attack()
    
    attack_pattern = (attack_pattern + 1) % 3

func area_attack() -> void:
    # Ataque em 360 graus
    pass

func charge_attack() -> void:
    # Boss corre em linha reta
    pass
```

### Minions

Boss pode spawnar inimigos:

```gdscript
var minion_timer: Timer
var max_minions: int = 3
var current_minions: int = 0

func spawn_minion() -> void:
    if current_minions < max_minions:
        var minion = preload("res://scenes/enemy/minion.tscn").instantiate()
        minion.global_position = global_position + Vector2(50, 0).rotated(randf() * TAU)
        get_parent().add_child(minion)
        current_minions += 1
```

## Referência Rápida

### Propriedades Importantes

```gdscript
# Em boss.gd
@export var boss_data: EnemyData
var player: Node2D          # Sempre conhece o player
var is_attacking: bool      # Se está executando ataque
var current_state: State    # IDLE, WALK, ATTACK, HURT, DEAD

# Em EnemyData.tres
max_health = 500.0          # Vida total
damage = 30.0               # Dano por hit
attack_range = 80.0         # Distância para iniciar ataque
attack_cooldown = 3.0       # Segundos entre ataques
attack_warning_delay = 0.5  # Segundos de aviso antes do dano
attack_hitbox_duration = 0.25  # Segundos causando dano
```

### Métodos Principais

```gdscript
func perform_attack()       # Executa sequência de ataque completa
func take_damage(amount)    # Recebe dano (não é stunado facilmente)
func die()                  # Morte do boss (emite sinal)
func apply_slow(%, duration)  # Reduz velocidade
func apply_stun(duration)   # Paralisa (50% de duração)
```
