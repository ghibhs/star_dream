# 📋 Checklist do Sistema de Magias

## ✅ O Que Você JÁ TEM (Completo)

### 1. Projétil Mágico ✅
```
✅ scenes/projectiles/magic_projectile.tscn
✅ scripts/projectiles/magic_projectile.gd
```
**Funcionalidades:**
- Movimento em direção
- Pierce (atravessa inimigos)
- Homing (persegue alvos)
- Knockback
- AnimatedSprite2D configurável
- Colisão com inimigos

**Usado por:** Fireball, Ice Bolt (modo projétil)

---

### 2. Área de Efeito ✅
```
✅ scenes/spells/magic_area.tscn
✅ scripts/spells/magic_area.gd
```
**Funcionalidades:**
- Área circular configurável
- Dano ao longo do tempo (DoT)
- Duração configurável
- Tick interval

**Usado por:** Explosões, áreas de dano contínuo

---

### 3. Raio Contínuo (Beam) ✅
```
✅ scenes/spells/ice_beam.tscn
✅ scripts/spells/ice_beam.gd
```
**Funcionalidades:**
- Raio laser contínuo
- Segue direção do mouse
- AnimatedSprite2D ou Line2D
- Slow effect nos inimigos
- Detecta paredes/obstáculos
- Consome mana continuamente

**Usado por:** Ice Beam

---

### 4. Sistema de Dados ✅
```
✅ resources/classes/SpellData.gd (classe de dados)
✅ resources/spells/fireball.tres
✅ resources/spells/ice_bolt.tres
✅ resources/spells/heal.tres
✅ resources/spells/speed_boost.tres
```

---

## 🆕 O Que FALTA Criar

### 5. Buff/Debuff (FALTA) 🔴
```
❌ scenes/spells/magic_buff.tscn
❌ scripts/spells/magic_buff.gd
```
**Funcionalidades Necessárias:**
- Aplicar modificadores temporários (velocidade, dano, defesa)
- Timer para duração
- Visual de efeito no player/inimigo
- Remover buff ao expirar
- Stackable ou não

**Será usado por:** Speed Boost, Shield, Strength Boost

---

### 6. Cura (FALTA) 🔴
```
❌ scenes/spells/magic_heal.tscn
❌ scripts/spells/magic_heal.gd
```
**Funcionalidades Necessárias:**
- Cura instantânea
- Cura ao longo do tempo (HoT)
- Partículas de cura
- Som de cura
- Efeito visual no player

**Será usado por:** Heal, Regeneration

---

### 7. Invocação (FUTURO) 🟡
```
⏳ scenes/spells/magic_summon.tscn
⏳ scripts/spells/magic_summon.gd
```
**Funcionalidades Futuras:**
- Instanciar criatura aliada
- IA básica de seguir/atacar
- Duração ou permanente
- Limite de invocações

**Será usado por:** Summon Wolf, Summon Golem

---

### 8. Teleporte (FUTURO) 🟡
```
⏳ scenes/spells/magic_teleport.tscn
⏳ scripts/spells/magic_teleport.gd
```
**Funcionalidades Futuras:**
- Teleporta player para posição do mouse
- Efeito visual de desaparecimento/reaparecimento
- Cooldown
- Verificação de colisão (não teleportar em parede)

**Será usado por:** Blink, Teleport

---

## 🎯 Prioridades

### 🔴 ALTA (Criar AGORA)
1. **magic_buff.tscn/gd** - Speed Boost já existe mas não tem cena própria
2. **magic_heal.tscn/gd** - Heal já existe mas não tem cena própria

### 🟡 MÉDIA (Criar depois)
3. **magic_summon.tscn/gd** - Feature nova
4. **magic_teleport.tscn/gd** - Feature nova

### 🟢 BAIXA (Futuro distante)
5. Shield spell
6. Transformation spells
7. Crowd control (stun, freeze)

---

## 🛠️ Template para Criar Novas Cenas

### Template: magic_buff.tscn
```gdscene
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/spells/magic_buff.gd" id="1"]

[node name="MagicBuff" type="Node2D"]
script = ExtResource("1")

[node name="Duration" type="Timer" parent="."]
wait_time = 5.0
one_shot = true

[node name="ParticleEffect" type="CPUParticles2D" parent="."]
emitting = false
amount = 20
lifetime = 1.0
```

### Template: magic_buff.gd
```gdscript
# magic_buff.gd
extends Node2D
class_name MagicBuff

var spell_data: SpellData
var target_node: Node2D
var original_stats: Dictionary = {}

@onready var duration_timer = $Duration
@onready var particles = $ParticleEffect

func _ready():
    duration_timer.timeout.connect(_on_duration_end)

func setup(spell: SpellData, target: Node2D):
    spell_data = spell
    target_node = target
    duration_timer.wait_time = spell.duration
    
    apply_buff()
    duration_timer.start()
    particles.emitting = true

func apply_buff():
    # Salva stats originais
    if target_node.has_method("get_move_speed"):
        original_stats["speed"] = target_node.get_move_speed()
    
    # Aplica modificadores
    if spell_data.speed_modifier != 1.0:
        target_node.move_speed *= spell_data.speed_modifier
    
    print("[BUFF] ✨ Aplicado: %s" % spell_data.spell_name)

func _on_duration_end():
    remove_buff()
    queue_free()

func remove_buff():
    # Restaura stats originais
    if "speed" in original_stats:
        target_node.move_speed = original_stats["speed"]
    
    print("[BUFF] ⏱️ Expirado: %s" % spell_data.spell_name)
```

---

## 📊 Status Atual do Sistema

```
✅ COMPLETO (3/8):
- Projétil
- Área de Efeito
- Raio Contínuo

🔴 FALTA CRIAR (2/8):
- Buff/Debuff
- Cura

🟡 FUTURO (3/8):
- Invocação
- Teleporte
- Crowd Control

PROGRESSO: ████████░░░░░ 37.5%
```

---

## 🎯 Próximos Passos Recomendados

1. **AGORA**: Criar `magic_buff.tscn` + `.gd`
   - Implementar Speed Boost funcional
   - Adicionar visual de partículas
   - Testar com player

2. **AGORA**: Criar `magic_heal.tscn` + `.gd`
   - Implementar cura instantânea
   - Adicionar efeito visual de cura
   - Testar com player

3. **DEPOIS**: Criar `magic_summon.tscn` + `.gd`
   - Implementar invocação básica
   - Criar IA simples para criatura

4. **DEPOIS**: Criar `magic_teleport.tscn` + `.gd`
   - Implementar teleporte instantâneo
   - Adicionar efeito visual

---

## 📁 Estrutura Final Desejada

```
scenes/spells/
├── magic_projectile.tscn ✅
├── magic_area.tscn ✅
├── ice_beam.tscn ✅
├── magic_buff.tscn ❌ (CRIAR)
├── magic_heal.tscn ❌ (CRIAR)
├── magic_summon.tscn ⏳ (FUTURO)
└── magic_teleport.tscn ⏳ (FUTURO)

scripts/spells/
├── magic_projectile.gd ✅
├── magic_area.gd ✅
├── ice_beam.gd ✅
├── magic_buff.gd ❌ (CRIAR)
├── magic_heal.gd ❌ (CRIAR)
├── magic_summon.gd ⏳ (FUTURO)
└── magic_teleport.gd ⏳ (FUTURO)
```

---

## ✨ Conclusão

**Você já tem 37.5% do sistema completo!** 🎉

As 3 cenas principais (Projétil, Área, Beam) estão prontas e funcionando.

**Foco agora**: Criar Buff e Heal para completar os tipos básicos de magia.

Quer que eu crie os templates de `magic_buff` e `magic_heal` para você? 🚀
