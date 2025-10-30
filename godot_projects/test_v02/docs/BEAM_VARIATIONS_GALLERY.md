# 🎨 Variações de Beam - Galeria de Exemplos

## 📖 Índice
1. [Lightning Beam (Relâmpago)](#lightning-beam)
2. [Fire Laser (Laser de Fogo)](#fire-laser)
3. [Ice Beam (Raio de Gelo)](#ice-beam)
4. [Healing Ray (Raio de Cura)](#healing-ray)
5. [Poison Stream (Jato Venenoso)](#poison-stream)
6. [Death Ray (Raio da Morte)](#death-ray)
7. [Prismatic Beam (Raio Prismático)](#prismatic-beam)
8. [Tractor Beam (Raio Trator)](#tractor-beam)

---

## ⚡ Lightning Beam

### Visual:
```
Player        ⚡⚡⚡⚡⚡⚡💥 Enemy
             ━━━━━━━━━━━━━━
             ⚡⚡⚡⚡⚡⚡⚡
```

### Configuração:
```gdscript
# Raio elétrico instável com alto dano
beam_color = Color(0.8, 0.9, 1.0, 0.9)  # Azul-branco brilhante
damage_per_second = 45.0
mana_cost_per_second = 18.0
max_range = 700.0
beam_width = 28.0

# Efeitos visuais energéticos
pulse_speed = 8.0  # Pulsação rápida
pulse_intensity = 0.4  # Muito variável
oscillation_speed = 10.0  # Oscila rápido
oscillation_amplitude = 5.0  # Ziguezague
```

### Efeito Especial:
```gdscript
# Adicionar chance de chain lightning
func _on_damage_tick():
    # ... dano normal ...
    
    # 30% chance de saltar para outro inimigo próximo
    if randf() < 0.3:
        var nearby = get_nearby_enemies(150.0)
        if nearby.size() > 0:
            nearby[0].take_damage(damage_per_second * 0.5, global_position)
            # Criar efeito visual de arco entre inimigos
```

---

## 🔥 Fire Laser

### Visual:
```
Player        ═══════════💥 Enemy
             ▬▬▬▬▬▬▬▬▬▬▬▬
```

### Configuração:
```gdscript
# Laser de fogo preciso com dano alto
beam_color = Color(1.0, 0.3, 0.0, 1.0)  # Laranja-vermelho
damage_per_second = 55.0
mana_cost_per_second = 20.0
max_range = 900.0
beam_width = 24.0

# Visual estável (laser focado)
pulse_speed = 2.0  # Pulsação lenta
pulse_intensity = 0.1  # Quase constante
oscillation_speed = 1.0  # Oscila pouco
oscillation_amplitude = 1.0  # Bem reto
```

### Efeito Especial:
```gdscript
# Aplicar burn (queimadura) ao inimigo
func _on_damage_tick():
    if current_target and current_target.has_method("apply_burn"):
        current_target.apply_burn(3.0, 2.0)  # 3 dps por 2s
```

---

## ❄️ Ice Beam

### Visual:
```
Player        ∼∼∼∼∼∼∼∼∼❄️ Enemy
             ≈≈≈≈≈≈≈≈≈≈≈
             ∼∼∼∼∼∼∼∼∼
```

### Configuração:
```gdscript
# Raio de gelo que diminui velocidade
beam_color = Color(0.3, 0.7, 1.0, 0.85)  # Azul claro
damage_per_second = 30.0
mana_cost_per_second = 12.0
max_range = 600.0
beam_width = 36.0  # Mais largo

# Visual fluido
pulse_speed = 3.0
pulse_intensity = 0.25
oscillation_speed = 4.0
oscillation_amplitude = 3.0
```

### Efeito Especial:
```gdscript
# Aplicar slow crescente
var slow_stacks: Dictionary = {}  # enemy: slow_amount

func _on_damage_tick():
    if current_target:
        # Aumentar slow a cada tick (máx 70%)
        if not slow_stacks.has(current_target):
            slow_stacks[current_target] = 0.0
        
        slow_stacks[current_target] = min(slow_stacks[current_target] + 0.1, 0.7)
        
        if current_target.has_method("apply_slow"):
            current_target.apply_slow(slow_stacks[current_target], 0.5)

func deactivate():
    # Limpar slows ao desativar
    slow_stacks.clear()
    # ... resto do código ...
```

---

## 💚 Healing Ray

### Visual:
```
Player        ✚✚✚✚✚✚✚✚✚ Ally
             ▓▓▓▓▓▓▓▓▓▓▓
             ✚✚✚✚✚✚✚✚✚
```

### Configuração:
```gdscript
# Raio de cura para aliados
beam_color = Color(0.3, 1.0, 0.3, 0.8)  # Verde brilhante
damage_per_second = -30.0  # Negativo = cura
mana_cost_per_second = 15.0
max_range = 500.0
beam_width = 32.0
collision_mask = 6  # Layer de aliados (não inimigos!)

# Visual suave
pulse_speed = 2.5
pulse_intensity = 0.15
oscillation_speed = 2.0
oscillation_amplitude = 2.0
```

### Modificação no Script:
```gdscript
func update_raycast() -> void:
    raycast.force_raycast_update()
    
    if raycast.is_colliding():
        var collision_point = raycast.get_collision_point()
        beam_length = global_position.distance_to(collision_point)
        
        var collider = raycast.get_collider()
        # Detectar aliados ao invés de inimigos
        if collider and collider.is_in_group("allies"):
            current_target = collider
        else:
            current_target = null
    else:
        beam_length = max_range
        current_target = null

func _on_damage_tick():
    if current_target and current_target.has_method("heal"):
        var heal_amount = abs(damage_per_second) * damage_timer.wait_time
        current_target.heal(heal_amount)
        print("[BEAM] 💚 Curou %.1f HP em %s" % [heal_amount, current_target.name])
```

---

## ☠️ Poison Stream

### Visual:
```
Player        ∿∿∿∿∿∿∿∿☠️ Enemy
             ∿∿∿∿∿∿∿∿∿∿
             ∿∿∿∿∿∿∿∿
```

### Configuração:
```gdscript
# Jato venenoso com DoT
beam_color = Color(0.5, 1.0, 0.3, 0.7)  # Verde ácido
damage_per_second = 20.0  # Dano inicial baixo
mana_cost_per_second = 10.0
max_range = 400.0  # Mais curto
beam_width = 40.0  # Bem largo

# Visual ondulante
pulse_speed = 4.0
pulse_intensity = 0.3
oscillation_speed = 6.0
oscillation_amplitude = 6.0  # Muito ondulante
```

### Efeito Especial:
```gdscript
# Aplicar veneno acumulativo
var poison_stacks: Dictionary = {}

func _on_damage_tick():
    if current_target:
        # Dano inicial
        var instant_damage = damage_per_second * damage_timer.wait_time
        current_target.take_damage(instant_damage, global_position)
        
        # Aplicar stack de veneno (5 dps por 3s, acumula)
        if current_target.has_method("apply_poison"):
            current_target.apply_poison(5.0, 3.0)  # Refresh duration
        
        # Tracking visual
        if not poison_stacks.has(current_target):
            poison_stacks[current_target] = 0
        poison_stacks[current_target] += 1
        
        print("[BEAM] ☠️ Veneno x%d" % poison_stacks[current_target])
```

---

## 💀 Death Ray

### Visual:
```
Player        ▓▓▓▓▓▓▓▓▓💀 Enemy
             ████████████
             ▓▓▓▓▓▓▓▓▓
```

### Configuração:
```gdscript
# Raio necrótico devastador
beam_color = Color(0.5, 0.0, 0.5, 1.0)  # Roxo escuro
damage_per_second = 80.0  # MUITO alto
mana_cost_per_second = 35.0  # MUITO caro
max_range = 500.0
beam_width = 48.0  # Grosso

# Visual intenso e ominoso
pulse_speed = 1.5
pulse_intensity = 0.5
oscillation_speed = 8.0
oscillation_amplitude = 8.0
```

### Efeito Especial:
```gdscript
# Drenar vida do inimigo para o player
func _on_damage_tick():
    if current_target:
        var damage = damage_per_second * damage_timer.wait_time
        current_target.take_damage(damage, global_position)
        
        # Drenar 30% do dano como vida
        if player and player.has_method("heal"):
            var lifesteal = damage * 0.3
            player.heal(lifesteal)
            print("[BEAM] 💀 Drenou %.1f HP" % lifesteal)
        
        # Visual: partículas vermelhas do inimigo para o player
        # create_lifesteal_particles(current_target.global_position, player.global_position)
```

---

## 🌈 Prismatic Beam

### Visual:
```
Player        🌈🌈🌈🌈🌈✨ Enemy
             ▓░▓░▓░▓░▓░▓
```

### Configuração:
```gdscript
# Raio multicolorido com efeitos variados
var beam_colors = [
    Color(1.0, 0.0, 0.0),  # Vermelho
    Color(1.0, 0.5, 0.0),  # Laranja
    Color(1.0, 1.0, 0.0),  # Amarelo
    Color(0.0, 1.0, 0.0),  # Verde
    Color(0.0, 0.0, 1.0),  # Azul
    Color(0.5, 0.0, 1.0),  # Roxo
]
var color_index: int = 0

damage_per_second = 35.0
mana_cost_per_second = 16.0
max_range = 750.0
beam_width = 32.0

pulse_speed = 6.0
pulse_intensity = 0.35
oscillation_speed = 5.0
oscillation_amplitude = 4.0
```

### Efeito Especial:
```gdscript
# Mudar de cor e efeito a cada segundo
var color_timer: float = 0.0

func _process(delta):
    # ... código existente ...
    
    # Trocar cor
    color_timer += delta
    if color_timer >= 1.0:
        color_timer = 0.0
        color_index = (color_index + 1) % beam_colors.size()
        beam_color = beam_colors[color_index]
        print("[BEAM] 🌈 Cor: %s" % ["Fogo", "Explosão", "Relâmpago", "Veneno", "Gelo", "Sombra"][color_index])

func _on_damage_tick():
    if not current_target:
        return
    
    # Efeito baseado na cor atual
    match color_index:
        0:  # Vermelho - Burn
            if current_target.has_method("apply_burn"):
                current_target.apply_burn(2.0, 1.0)
        1:  # Laranja - Knockback
            apply_knockback(current_target, 150.0)
        2:  # Amarelo - Stun
            if current_target.has_method("apply_stun"):
                current_target.apply_stun(0.3)
        3:  # Verde - Poison
            if current_target.has_method("apply_poison"):
                current_target.apply_poison(3.0, 2.0)
        4:  # Azul - Slow
            if current_target.has_method("apply_slow"):
                current_target.apply_slow(0.5, 0.5)
        5:  # Roxo - Lifesteal
            if player and player.has_method("heal"):
                player.heal(2.0)
    
    # Dano base
    current_target.take_damage(damage_per_second * damage_timer.wait_time, global_position)
```

---

## 🛸 Tractor Beam

### Visual:
```
Player        )))))))))) Enemy
             ═══════════ ←─
             (((((((((((
```

### Configuração:
```gdscript
# Raio que puxa inimigos
beam_color = Color(0.4, 0.8, 1.0, 0.6)  # Azul translúcido
damage_per_second = 10.0  # Dano baixo
mana_cost_per_second = 8.0
max_range = 600.0
beam_width = 40.0

pulse_speed = 5.0
pulse_intensity = 0.2
oscillation_speed = 0.0  # Sem oscilação
oscillation_amplitude = 0.0
```

### Efeito Especial:
```gdscript
# Puxar inimigo em direção ao player
func _process(delta):
    # ... código existente ...
    
    if is_active and current_target:
        apply_tractor_force(delta)

func apply_tractor_force(delta: float):
    if not current_target or not current_target is CharacterBody2D:
        return
    
    # Calcular direção do inimigo para o player
    var pull_direction = (global_position - current_target.global_position).normalized()
    var pull_force = 150.0  # Força de atração
    
    # Aplicar velocidade ao inimigo
    if current_target.has_method("apply_velocity"):
        current_target.apply_velocity(pull_direction * pull_force * delta)
    else:
        # Fallback: mover diretamente
        current_target.global_position += pull_direction * pull_force * delta
    
    print("[BEAM] 🛸 Puxando inimigo...")

func _on_damage_tick():
    # Dano mínimo, efeito principal é puxar
    if current_target:
        current_target.take_damage(damage_per_second * damage_timer.wait_time, global_position)
```

---

## 🔧 Template para Criar Seu Próprio Beam

```gdscript
# ===== CONFIGURAÇÃO BÁSICA =====
beam_color = Color(?, ?, ?, ?)  # R, G, B, A
damage_per_second = ?
mana_cost_per_second = ?
max_range = ?
beam_width = ?

# ===== EFEITOS VISUAIS =====
pulse_speed = ?         # 1-10 (lento-rápido)
pulse_intensity = ?     # 0-1 (sutil-intenso)
oscillation_speed = ?   # 0-10 (reto-ondulado)
oscillation_amplitude = ? # 0-10 (pequeno-grande)

# ===== EFEITO ESPECIAL (OPCIONAL) =====
func _on_damage_tick():
    if current_target:
        # Dano base
        current_target.take_damage(damage_per_second * damage_timer.wait_time, global_position)
        
        # SEU EFEITO AQUI:
        # - apply_burn(dps, duration)
        # - apply_slow(amount, duration)
        # - apply_poison(dps, duration)
        # - apply_stun(duration)
        # - heal(amount)
        # - etc.
```

---

## 🎨 Paleta de Cores Sugeridas

```gdscript
# Fogo/Calor
Color(1.0, 0.3, 0.0)    # Laranja
Color(1.0, 0.1, 0.0)    # Vermelho
Color(1.0, 0.8, 0.0)    # Amarelo-laranja

# Gelo/Frio
Color(0.3, 0.7, 1.0)    # Azul claro
Color(0.5, 0.9, 1.0)    # Ciano
Color(0.6, 0.8, 0.95)   # Azul gelo

# Elétrico/Energia
Color(0.8, 0.9, 1.0)    # Azul-branco
Color(0.5, 0.8, 1.0)    # Azul elétrico
Color(1.0, 1.0, 0.8)    # Branco-amarelo

# Veneno/Ácido
Color(0.5, 1.0, 0.3)    # Verde limão
Color(0.3, 0.8, 0.2)    # Verde escuro
Color(0.7, 1.0, 0.0)    # Verde ácido

# Morte/Sombra
Color(0.5, 0.0, 0.5)    # Roxo escuro
Color(0.3, 0.0, 0.3)    # Roxo sombrio
Color(0.2, 0.2, 0.2)    # Cinza escuro

# Cura/Sagrado
Color(0.3, 1.0, 0.3)    # Verde cura
Color(1.0, 0.9, 0.5)    # Dourado
Color(1.0, 1.0, 1.0)    # Branco puro
```

---

## 🎯 Combinações de Efeitos

### Beam de Controle de Grupo:
```gdscript
# Combinar slow + knockback
damage_per_second = 25.0
# Slow 50% + empurra 100 units
```

### Beam Vampírico:
```gdscript
# Alto dano + lifesteal
damage_per_second = 60.0
# Drena 40% como HP
```

### Beam de Debuff:
```gdscript
# Dano baixo + múltiplos debuffs
damage_per_second = 15.0
# Aplica: slow, poison, reduce defense
```

### Beam Explosivo:
```gdscript
# Dano médio + área no impacto
damage_per_second = 30.0
# Cria explosão 100px radius ao redor do alvo
```

---

## 📊 Comparação de Stats

| Tipo | DPS | Mana/s | Range | Width | Uso |
|------|-----|--------|-------|-------|-----|
| Lightning | 45 | 18 | 700 | 28 | Alto burst |
| Fire Laser | 55 | 20 | 900 | 24 | Precisão |
| Ice | 30 | 12 | 600 | 36 | Controle |
| Heal | 30 | 15 | 500 | 32 | Suporte |
| Poison | 20 | 10 | 400 | 40 | DoT |
| Death | 80 | 35 | 500 | 48 | Boss killer |
| Prismatic | 35 | 16 | 750 | 32 | Versatilidade |
| Tractor | 10 | 8 | 600 | 40 | Utilitário |

---

## ✨ Dicas de Design

### 1. Balance Dano vs Mana
- Alto dano = Alto custo de mana
- Baixo dano = Pode ser usado por mais tempo

### 2. Range vs Width
- Longo alcance = Raio fino (laser)
- Curto alcance = Raio grosso (jato)

### 3. Efeitos Visuais
- Raios estáveis = Menos oscilação
- Raios caóticos = Muita oscilação
- Energia = Pulsação rápida
- Fluidos = Pulsação lenta

### 4. Efeitos Especiais
- Controle de grupo = Slow/Stun
- Sustain = Lifesteal/Regen
- Burst = Alto dano single target
- AoE = Chain/Explosões

---

**Escolha seu beam favorito e comece a destruir inimigos!** ⚡🔥❄️

