extends HBoxContainer
class_name SpellSelectorUI

## Sistema de seleção visual de magias com rolagem Q/E
## Posicionado abaixo da barra de mana

# ========================================
# SINAIS
# ========================================

signal spell_selected(spell_data: SpellData)
signal spell_changed(old_index: int, new_index: int)

# ========================================
# VARIÁVEIS
# ========================================

@export var spell_slot_scene: PackedScene
@export var slot_size: Vector2 = Vector2(48, 48)
@export var slot_spacing: int = 8
@export var max_visible_slots: int = 5  # Quantos slots aparecem por vez

var available_spells: Array[SpellData] = []
var spell_slots: Array[Control] = []
var current_spell_index: int = 0

# Cores
var selected_color: Color = Color(1.0, 1.0, 0.0, 1.0)  # Amarelo
var normal_color: Color = Color(0.8, 0.8, 0.8, 1.0)    # Cinza claro
var locked_color: Color = Color(0.3, 0.3, 0.3, 1.0)     # Cinza escuro

# ========================================
# FUNÇÕES BUILT-IN
# ========================================

func _ready() -> void:
	custom_minimum_size = Vector2(slot_size.x * max_visible_slots + slot_spacing * (max_visible_slots - 1), slot_size.y)
	add_theme_constant_override("separation", slot_spacing)
	
	print("\n[SPELL_SELECTOR] ═══════════════════════════════")
	print("[SPELL_SELECTOR] 🎯 INICIALIZANDO...")
	print("[SPELL_SELECTOR]    Tamanho dos slots: ", slot_size)
	print("[SPELL_SELECTOR]    Máximo visível: ", max_visible_slots)
	print("[SPELL_SELECTOR]    Node name: ", name)
	if get_parent():
		print("[SPELL_SELECTOR]    Parent: ", get_parent().name)
	print("[SPELL_SELECTOR]    Position: ", position)
	print("[SPELL_SELECTOR]    Visible: ", visible)
	print("[SPELL_SELECTOR] ═══════════════════════════════\n")


# ========================================
# GERENCIAMENTO DE MAGIAS
# ========================================

func setup_spells(spells: Array[SpellData]) -> void:
	"""Configura as magias disponíveis e cria os slots visuais"""
	if spells.is_empty():
		print("[SPELL_SELECTOR] ⚠️ Nenhuma magia fornecida")
		return
	
	available_spells = spells
	current_spell_index = 0
	
	# Limpa slots anteriores
	clear_slots()
	
	# Cria novos slots
	create_slots()
	
	# Atualiza visual
	update_selection()
	
	print("[SPELL_SELECTOR] ✅ %d magias configuradas" % available_spells.size())
	for i in range(available_spells.size()):
		print("[SPELL_SELECTOR]    [%d] %s" % [i, available_spells[i].spell_name])


func clear_slots() -> void:
	"""Remove todos os slots existentes"""
	for slot in spell_slots:
		if is_instance_valid(slot):
			slot.queue_free()
	spell_slots.clear()


func create_slots() -> void:
	"""Cria os slots visuais para as magias"""
	for i in range(available_spells.size()):
		var slot = create_spell_slot(i)
		add_child(slot)
		spell_slots.append(slot)


func create_spell_slot(index: int) -> Control:
	"""Cria um slot individual de magia"""
	var slot = Panel.new()
	slot.custom_minimum_size = slot_size
	slot.name = "SpellSlot_%d" % index
	
	# Torna o slot clicável
	slot.mouse_filter = Control.MOUSE_FILTER_PASS
	
	# Conecta sinais de mouse
	slot.gui_input.connect(_on_slot_gui_input.bind(index))
	slot.mouse_entered.connect(_on_slot_mouse_entered.bind(index))
	slot.mouse_exited.connect(_on_slot_mouse_exited.bind(index))
	
	# Container vertical para ícone + nome
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 2)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Deixa cliques passarem para o Panel
	slot.add_child(vbox)
	
	# Ícone da magia (placeholder - pode ser sprite depois)
	var icon = ColorRect.new()
	icon.custom_minimum_size = Vector2(slot_size.x - 8, slot_size.y - 20)
	icon.color = get_spell_color(available_spells[index])
	icon.name = "Icon"
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(icon)
	
	# Nome da magia
	var label = Label.new()
	label.text = available_spells[index].spell_name.substr(0, 6)  # Primeiras 6 letras
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 10)
	label.name = "Label"
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(label)
	
	# Borda para indicar seleção
	var border = Panel.new()
	border.set_anchors_preset(Control.PRESET_FULL_RECT)
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	border.name = "Border"
	slot.add_child(border)
	
	# Adiciona ao container do slot para estilização
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = normal_color
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	slot.add_theme_stylebox_override("panel", style)
	
	return slot


func get_spell_color(spell: SpellData) -> Color:
	"""Retorna uma cor baseada no tipo de magia"""
	match spell.spell_type:
		SpellData.SpellType.PROJECTILE:
			return Color(1.0, 0.5, 0.0, 1.0)  # Laranja - Fireball
		SpellData.SpellType.BEAM:
			return Color(0.2, 0.7, 1.0, 1.0)  # Azul claro - Ice Beam
		SpellData.SpellType.TARGETED:
			return Color(1.0, 1.0, 0.0, 1.0)  # Amarelo - Lightning Strike
		_:
			return Color(0.7, 0.7, 0.7, 1.0)  # Cinza


# ========================================
# NAVEGAÇÃO
# ========================================

func select_next_spell() -> void:
	"""Seleciona a próxima magia (tecla E)"""
	if available_spells.is_empty():
		return
	
	var old_index = current_spell_index
	current_spell_index = (current_spell_index + 1) % available_spells.size()
	
	update_selection()
	spell_changed.emit(old_index, current_spell_index)
	spell_selected.emit(available_spells[current_spell_index])
	
	print("[SPELL_SELECTOR] ➡️ Próxima: [%d] %s" % [current_spell_index, available_spells[current_spell_index].spell_name])


func select_previous_spell() -> void:
	"""Seleciona a magia anterior (tecla Q)"""
	if available_spells.is_empty():
		return
	
	var old_index = current_spell_index
	current_spell_index = (current_spell_index - 1 + available_spells.size()) % available_spells.size()
	
	update_selection()
	spell_changed.emit(old_index, current_spell_index)
	spell_selected.emit(available_spells[current_spell_index])
	
	print("[SPELL_SELECTOR] ⬅️ Anterior: [%d] %s" % [current_spell_index, available_spells[current_spell_index].spell_name])


func select_spell_by_index(index: int) -> void:
	"""Seleciona uma magia específica por índice"""
	if index < 0 or index >= available_spells.size():
		print("[SPELL_SELECTOR] ⚠️ Índice inválido: %d" % index)
		return
	
	var old_index = current_spell_index
	current_spell_index = index
	
	update_selection()
	spell_changed.emit(old_index, current_spell_index)
	spell_selected.emit(available_spells[current_spell_index])
	
	print("[SPELL_SELECTOR] 🎯 Selecionado: [%d] %s" % [current_spell_index, available_spells[current_spell_index].spell_name])


# ========================================
# ATUALIZAÇÃO VISUAL
# ========================================

func update_selection() -> void:
	"""Atualiza o visual dos slots para mostrar a seleção atual"""
	for i in range(spell_slots.size()):
		var slot = spell_slots[i]
		if not is_instance_valid(slot):
			continue
		
		var style = slot.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
		
		if i == current_spell_index:
			# Slot selecionado - borda amarela brilhante
			style.border_color = selected_color
			style.border_width_left = 4
			style.border_width_right = 4
			style.border_width_top = 4
			style.border_width_bottom = 4
			style.bg_color = Color(0.3, 0.3, 0.1, 0.9)  # Fundo amarelado
		else:
			# Slot normal
			style.border_color = normal_color
			style.border_width_left = 2
			style.border_width_right = 2
			style.border_width_top = 2
			style.border_width_bottom = 2
			style.bg_color = Color(0.2, 0.2, 0.2, 0.8)
		
		slot.add_theme_stylebox_override("panel", style)


# ========================================
# GETTERS
# ========================================

func get_current_spell() -> SpellData:
	"""Retorna a magia atualmente selecionada"""
	if available_spells.is_empty():
		return null
	return available_spells[current_spell_index]


func get_spell_count() -> int:
	"""Retorna o número de magias disponíveis"""
	return available_spells.size()


func is_spell_selected() -> bool:
	"""Verifica se há uma magia selecionada"""
	return not available_spells.is_empty()


# ========================================
# INTERAÇÃO COM MOUSE
# ========================================

func _on_slot_gui_input(event: InputEvent, index: int) -> void:
	"""Detecta clique no slot"""
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Clique esquerdo - seleciona a magia
			select_spell_by_index(index)
			print("[SPELL_SELECTOR] 🖱️ Clicado no slot %d" % index)


func _on_slot_mouse_entered(index: int) -> void:
	"""Quando o mouse entra no slot"""
	if index < 0 or index >= spell_slots.size():
		return
	
	var slot = spell_slots[index]
	if not is_instance_valid(slot):
		return
	
	# Efeito de hover - borda mais clara
	var style = slot.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	if index != current_spell_index:
		style.border_color = Color(1.0, 1.0, 1.0, 1.0)  # Branco ao passar o mouse
	slot.add_theme_stylebox_override("panel", style)


func _on_slot_mouse_exited(_index: int) -> void:
	"""Quando o mouse sai do slot"""
	# Restaura o visual normal
	update_selection()


# ========================================
# DEBUG
# ========================================

func _to_string() -> String:
	return "[SpellSelectorUI] %d spells, current: %d (%s)" % [
		available_spells.size(),
		current_spell_index,
		available_spells[current_spell_index].spell_name if not available_spells.is_empty() else "none"
	]
