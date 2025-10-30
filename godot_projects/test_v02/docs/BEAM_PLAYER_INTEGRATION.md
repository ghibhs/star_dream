# 🔌 INTEGRAÇÃO DO BEAM NO PLAYER - Exemplo Completo

## 📝 Código para Adicionar no `player.gd`

### 1. Adicionar no topo (com outros preloads):
```gdscript
# Preload das cenas de magias
const ContinuousBeamScene = preload("res://scenes/spells/continuous_beam.tscn")
```

### 2. Adicionar nas variáveis (próximo a outras variáveis de spell):
```gdscript
# Sistema de Raio Contínuo
var lightning_beam: ContinuousBeam = null
var is_casting_beam: bool = false
var beam_spell_data: SpellData = null
```

### 3. Adicionar no `_ready()`:
```gdscript
func _ready() -> void:
	# ... código existente ...
	
	# Configurar beam spell
	setup_lightning_beam()
```

### 4. Adicionar nova função de setup:
```gdscript
func setup_lightning_beam() -> void:
	"""Inicializa o sistema de raio contínuo"""
	print("[PLAYER] ⚡ Configurando Lightning Beam...")
	
	# Tentar carregar SpellData (opcional)
	var beam_path = "res://resources/spells/lightning_beam.tres"
	if ResourceLoader.exists(beam_path):
		beam_spell_data = load(beam_path)
		print("[PLAYER] 📚 Lightning Beam data carregado")
	else:
		print("[PLAYER] ⚠️ Lightning Beam data não encontrado, usando valores padrão")
	
	# Instanciar a cena do beam
	lightning_beam = ContinuousBeamScene.instantiate()
	add_child(lightning_beam)
	
	# Configurar o beam com referência ao player
	lightning_beam.setup(self, beam_spell_data)
	
	print("[PLAYER] ✅ Lightning Beam configurado e pronto")
```

### 5. Adicionar no `_process(delta)`:
```gdscript
func _process(delta: float) -> void:
	# ... código existente ...
	
	# Atualizar beam casting
	handle_beam_casting()
```

### 6. Adicionar nova função de input:
```gdscript
func handle_beam_casting() -> void:
	"""Gerencia o input do raio contínuo"""
	
	# Verificar se está segurando Shift + Botão Direito
	var wants_to_cast = Input.is_action_pressed("cast_beam") or \
	                    (Input.is_key_pressed(KEY_SHIFT) and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT))
	
	if wants_to_cast:
		# Tentar iniciar casting
		if not is_casting_beam:
			if can_cast_beam():
				start_beam_casting()
	else:
		# Parar casting se estava ativo
		if is_casting_beam:
			stop_beam_casting()
```

### 7. Adicionar funções de controle:
```gdscript
func can_cast_beam() -> bool:
	"""Verifica se pode conjurar o raio"""
	# Verificar mana mínima
	if current_mana < 5.0:
		print("[PLAYER] ⚠️ Mana insuficiente para conjurar raio")
		return false
	
	# Verificar se não está em outro estado que impede casting
	if is_dashing:
		return false
	
	return true

func start_beam_casting() -> void:
	"""Inicia a conjuração do raio"""
	if not lightning_beam:
		print("[PLAYER] ❌ Lightning beam não inicializado!")
		return
	
	is_casting_beam = true
	lightning_beam.activate()
	print("[PLAYER] ⚡ Lightning Beam ATIVADO")
	
	# Opcional: tocar som de início
	# if cast_sound:
	#     cast_sound.play()

func stop_beam_casting() -> void:
	"""Para a conjuração do raio"""
	if not lightning_beam:
		return
	
	is_casting_beam = false
	lightning_beam.deactivate()
	print("[PLAYER] ⏹️ Lightning Beam DESATIVADO")
	
	# Opcional: tocar som de fim
	# if cast_end_sound:
	#     cast_end_sound.play()
```

### 8. (Opcional) Adicionar no `_exit_tree()`:
```gdscript
func _exit_tree() -> void:
	# ... código existente ...
	
	# Limpar beam
	if lightning_beam:
		lightning_beam.queue_free()
```

---

## ⚙️ Configurar Input Map

No Godot Editor:
```
Project > Project Settings > Input Map

1. Adicionar nova ação: "cast_beam"
2. Clicar no + ao lado
3. Escolher: Mouse Button Index > Right Button
4. OU: Key > Shift
```

Ou adicionar via código no `project.godot`:
```ini
[input]

cast_beam={
"deadzone": 0.5,
"events": [Object(InputEventMouseButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"button_mask":2,"position":Vector2(0, 0),"global_position":Vector2(0, 0),"factor":1.0,"button_index":2,"canceled":false,"pressed":true,"double_click":false,"script":null)
]
}
```

---

## 📦 Criar SpellData (Opcional)

Criar arquivo: `resources/spells/lightning_beam.tres`

```gdscript
[gd_resource type="Resource" script_class="SpellData" load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/resources/spell_data.gd" id="1"]

[resource]
script = ExtResource("1")
spell_id = "lightning_beam"
spell_name = "Lightning Beam"
spell_description = "Raio contínuo de relâmpagos que causa dano enquanto ativo"
spell_type = 4  # BEAM
element = 3  # LIGHTNING
mana_cost = 20.0  # Custo por segundo
damage = 35.0  # Dano por segundo
max_range = 800.0
cast_time = 0.0
cooldown = 0.0
icon_path = "res://art/icons/lightning_beam_icon.png"
```

---

## 🎮 Variação: Beam Selecionável (Integração com Spell Selector)

Se você quiser que o beam seja uma magia selecionável no spell selector:

### Adicionar no `load_available_spells()`:
```gdscript
func load_available_spells() -> void:
	available_spells.clear()
	
	# ... magias existentes ...
	
	# Lightning Beam
	var lightning = load("res://resources/spells/lightning_beam.tres")
	if lightning:
		available_spells.append(lightning)
		print("[PLAYER] ⚡ Lightning Beam adicionado")
	
	print("[PLAYER] 📚 Total de magias carregadas: %d" % available_spells.size())
```

### Modificar `cast_current_spell()`:
```gdscript
func cast_current_spell() -> void:
	if available_spells.is_empty():
		return
	
	var spell = available_spells[current_spell_index]
	
	# ... código existente ...
	
	# Adicionar case para BEAM
	match spell.spell_type:
		SpellData.SpellType.PROJECTILE:
			cast_projectile_spell(spell)
		SpellData.SpellType.AREA:
			cast_area_spell(spell)
		SpellData.SpellType.BUFF:
			cast_buff_spell(spell)
		SpellData.SpellType.HEAL:
			cast_heal_spell(spell)
		SpellData.SpellType.BEAM:
			cast_beam_spell(spell)  # NOVO
```

### Adicionar função de cast:
```gdscript
func cast_beam_spell(spell: SpellData) -> void:
	"""Inicia o beam se for a primeira vez"""
	if not lightning_beam:
		setup_lightning_beam()
	
	# Atualizar spell data
	beam_spell_data = spell
	if lightning_beam:
		lightning_beam.setup(self, spell)
	
	print("[PLAYER] ⚡ Beam spell preparado: %s" % spell.spell_name)
```

### Input alternativo (usar botão de cast):
```gdscript
func _unhandled_input(event: InputEvent) -> void:
	# Cast normal (projectile, area, buff, heal)
	if event.is_action_pressed("cast_spell"):
		if available_spells[current_spell_index].spell_type != SpellData.SpellType.BEAM:
			cast_current_spell()
	
	# Beam contínuo (segurar botão)
	if Input.is_action_pressed("cast_spell"):
		if available_spells[current_spell_index].spell_type == SpellData.SpellType.BEAM:
			if not is_casting_beam:
				start_beam_casting()
	else:
		if is_casting_beam:
			stop_beam_casting()
```

---

## 🎨 Feedback Visual no Player

### Adicionar efeito visual quando está conjurando:
```gdscript
func start_beam_casting() -> void:
	# ... código existente ...
	
	# Mudar cor do sprite (feedback visual)
	if animated_sprite:
		animated_sprite.modulate = Color(0.5, 0.8, 1.0)  # Azulado
	
	# Ou adicionar partículas nas mãos
	# if hand_particles:
	#     hand_particles.emitting = true

func stop_beam_casting() -> void:
	# ... código existente ...
	
	# Restaurar cor
	if animated_sprite:
		animated_sprite.modulate = Color.WHITE
	
	# Parar partículas
	# if hand_particles:
	#     hand_particles.emitting = false
```

---

## 🐛 Debug/Testing

### Adicionar teclas de debug:
```gdscript
func _unhandled_input(event: InputEvent) -> void:
	# ... código existente ...
	
	# Debug: F5 para testar beam
	if event.is_action_pressed("ui_page_down"):  # F5
		if is_casting_beam:
			stop_beam_casting()
		else:
			if can_cast_beam():
				start_beam_casting()
		print("[DEBUG] Beam toggle: %s" % is_casting_beam)
```

### Prints úteis:
```gdscript
# No _process, adicionar debug visual:
if is_casting_beam and lightning_beam:
	# Mostrar info do beam
	$DebugLabel.text = "Beam Active\nMana: %.1f\nLength: %.1f" % \
	                   [current_mana, lightning_beam.beam_length]
```

---

## ✅ Checklist de Integração

- [ ] Código adicionado no player.gd
- [ ] Input "cast_beam" configurado
- [ ] Cena continuous_beam.tscn existe
- [ ] Sprites placeholder criados (ou customizados)
- [ ] SpellData criado (opcional)
- [ ] Testado em jogo:
  - [ ] Beam aparece ao pressionar botão
  - [ ] Segue o mouse
  - [ ] Aplica dano em inimigos
  - [ ] Consome mana
  - [ ] Desliga ao soltar botão
  - [ ] Para quando mana acaba

---

## 🎯 Resultado Esperado

**Ao segurar Shift + Botão Direito:**
- ⚡ Raio azul brilhante aparece do player
- 🎯 Segue o mouse em tempo real
- 💥 Mostra impacto quando acerta algo
- 🔥 Inimigos perdem HP continuamente
- 💧 Barra de mana diminui gradualmente
- ⏹️ Raio some ao soltar o botão

---

**Pronto para usar!** 🚀
