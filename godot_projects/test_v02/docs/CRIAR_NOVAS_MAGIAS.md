# 📝 Como Adicionar Novas Magias

## 🚀 Passo a Passo Rápido

### 1. Criar o Arquivo .tres da Magia

Vá em `resources/spells/` e crie um novo arquivo `.tres` (ou duplique um existente).

**Exemplo: Lightning Strike (Raio)**

```gdresource
[gd_resource type="Resource" script_class="SpellData" load_steps=2 format=3]

[ext_resource type="Script" path="res://resources/classes/SpellData.gd" id="1"]

[resource]
script = ExtResource("1")
spell_id = "lightning_strike"
spell_name = "Raio Devastador"
description = "Invoca um raio do céu que causa dano massivo em área"
spell_type = 1  # 0=PROJECTILE, 1=AREA, 2=BUFF, 3=DEBUFF, 4=HEAL
element = 3  # 0=NONE, 1=FIRE, 2=ICE, 3=LIGHTNING, 4=NATURE, 5=DARK, 6=LIGHT, 7=ARCANE
mana_cost = 30.0
cast_time = 1.0
cooldown = 5.0
damage = 50.0
spell_range = 600.0

# Para PROJECTILE
projectile_speed = 0.0
projectile_scale = Vector2(1, 1)
pierce = false
homing = false

# Para AREA
area_radius = 150.0
area_duration = 0.5
damage_over_time = false
tick_interval = 0.1

# Para BUFF/DEBUFF
duration = 0.0
speed_modifier = 1.0
damage_modifier = 1.0
defense_modifier = 1.0

# Para HEAL
heal_amount = 0.0
heal_over_time = false
heal_duration = 0.0

# Visual
spell_color = Color(1, 1, 0, 1)  # Amarelo elétrico

# Avançado
can_be_interrupted = true
requires_target = true  # Cai no mouse
max_targets = 5
knockback_force = 200.0
```

---

### 2. Adicionar no Player

Abra `scripts/player/player.gd` e adicione na função `load_available_spells()`:

```gdscript
func load_available_spells() -> void:
	available_spells.clear()
	
	var fireball = load("res://resources/spells/fireball.tres")
	var ice_bolt = load("res://resources/spells/ice_bolt.tres")
	var heal = load("res://resources/spells/heal.tres")
	var speed_boost = load("res://resources/spells/speed_boost.tres")
	var lightning = load("res://resources/spells/lightning_strike.tres")  # ← NOVO
	
	if fireball:
		available_spells.append(fireball)
	if ice_bolt:
		available_spells.append(ice_bolt)
	if heal:
		available_spells.append(heal)
	if speed_boost:
		available_spells.append(speed_boost)
	if lightning:  # ← NOVO
		available_spells.append(lightning)
		print("[PLAYER]    ⚡ Lightning Strike carregada")
```

**Pronto!** A magia já está funcional! 🎉

---

## 📋 Templates por Tipo

### 🔫 Template: Magia de Projétil
```
spell_type = 0  # PROJECTILE
damage = 20.0
projectile_speed = 400.0
projectile_scale = Vector2(1.5, 1.5)
pierce = false  # true = atravessa inimigos
homing = false  # true = persegue inimigos
knockback_force = 50.0
```

**Bom para:** Bola de fogo, flechas mágicas, raios direcionais

---

### 💥 Template: Magia de Área
```
spell_type = 1  # AREA
damage = 30.0
area_radius = 100.0
area_duration = 2.0
damage_over_time = true  # false = dano instantâneo, true = dano contínuo
tick_interval = 0.5  # dano a cada 0.5s
knockback_force = 100.0  # empurra inimigos para fora
requires_target = true  # true = cai no mouse, false = no jogador
```

**Bom para:** Explosões, campos de fogo, chuva de meteoros

---

### ✨ Template: Magia de Buff
```
spell_type = 2  # BUFF
duration = 10.0  # duração em segundos
speed_modifier = 1.5  # 1.5 = +50% velocidade
damage_modifier = 1.3  # 1.3 = +30% dano
defense_modifier = 0.8  # 0.8 = -20% dano recebido
```

**Bom para:** Aumentar velocidade, força, defesa

---

### 💚 Template: Magia de Cura
```
spell_type = 4  # HEAL
heal_amount = 50.0  # quantidade de HP restaurada
heal_over_time = false  # true = cura gradual
heal_duration = 5.0  # se HoT, duração da cura
```

**Bom para:** Cura instantânea, regeneração

---

## 🎨 Cores Sugeridas por Elemento

```gdscript
# Fogo
spell_color = Color(1, 0.3, 0, 1)  # Laranja/Vermelho

# Gelo
spell_color = Color(0.2, 0.7, 1, 1)  # Azul claro

# Raio
spell_color = Color(1, 1, 0.3, 1)  # Amarelo elétrico

# Natureza
spell_color = Color(0.2, 1, 0.3, 1)  # Verde

# Trevas
spell_color = Color(0.3, 0, 0.5, 1)  # Roxo escuro

# Luz
spell_color = Color(1, 1, 0.8, 1)  # Branco/Dourado

# Arcano
spell_color = Color(0.6, 0.3, 1, 1)  # Roxo mágico
```

---

## 💡 Ideias de Magias

### Ofensivas
- 🔥 **Meteor Shower** - Área de meteoros caindo (AREA + DoT)
- ⚡ **Chain Lightning** - Projétil que pula entre inimigos (PROJECTILE + homing)
- 🧊 **Frost Nova** - Explosão de gelo ao redor do jogador (AREA instantâneo)
- 🌪️ **Tornado** - Área que puxa inimigos (AREA + knockback negativo)

### Defensivas/Utilitárias
- 🛡️ **Shield** - Reduz dano recebido (BUFF com defense_modifier < 1.0)
- 🏃 **Dash Boost** - Velocidade extrema temporária (BUFF speed_modifier = 2.0)
- 💪 **Berserk** - Aumenta dano mas reduz defesa (BUFF damage + defense)
- 🌟 **Invulnerability** - Invencível por 2s (BUFF defense_modifier = 0.0)

### Curas
- 💚 **Regeneration** - Cura gradual (HEAL + heal_over_time)
- 🌿 **Nature's Blessing** - Cura total (HEAL heal_amount = max_health)
- ⛲ **Healing Fountain** - Área de cura (AREA + HEAL híbrido)*

*Nota: Para híbridos, você pode criar uma nova cena específica

---

## ⚠️ Dicas Importantes

1. **Mana Cost** deve ser balanceado com o poder da magia
   - Projétil simples: 10-15
   - Área média: 20-30
   - Buff forte: 25-35
   - Cura completa: 30-40

2. **Cooldown** evita spam
   - Projéteis rápidos: 0.5-1s
   - Magias fortes: 3-5s
   - Ultimates: 10-20s

3. **Damage** deve ser balanceado
   - Projétil: 20-30
   - Área instantânea: 30-50
   - Área DoT: 5-10 por tick

4. **Speed dos Projéteis**
   - Lentos (previsíveis): 300-400
   - Normais: 400-500
   - Rápidos: 500-700

---

## 🔄 Modificando Magias Existentes

Para alterar uma magia existente, basta editar o arquivo `.tres`:

1. Abra `resources/spells/fireball.tres`
2. Altere os valores (ex: `damage = 50.0`)
3. Salve
4. Reload no Godot (Ctrl+R)
5. Teste!

Mudanças são aplicadas **instantaneamente** sem mexer no código! 🎯

---

## 🎯 Checklist para Nova Magia

- [ ] Arquivo `.tres` criado em `resources/spells/`
- [ ] `spell_id` único
- [ ] `spell_name` e `description` preenchidos
- [ ] `spell_type` correto (0-4)
- [ ] `mana_cost` balanceado
- [ ] `damage` configurado (se aplicável)
- [ ] Propriedades específicas do tipo preenchidas
- [ ] `spell_color` escolhida
- [ ] Adicionado em `load_available_spells()` no player.gd
- [ ] Testado no jogo!

---

**Agora você pode criar quantas magias quiser facilmente! 🪄✨**
