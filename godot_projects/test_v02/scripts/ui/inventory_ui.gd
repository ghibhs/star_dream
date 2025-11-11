extends CanvasLayer
class_name InventoryUI

## UI principal do inventário com drag and drop, split, e equipamentos

@export var inventory: Inventory
@export var grid_columns: int = 6
@export var slot_size: Vector2 = Vector2(64, 64)
@export var slot_spacing: int = 4

var slot_uis: Array[InventorySlotUI] = []
var is_open: bool = false
var hotbar_ui: HotbarUI = null  # Referência ao hotbar para drag and drop

# Drag state
var dragging_from_slot: int = -1
var dragging_to_hotbar: bool = false

# Keyboard navigation - NAVEGAÇÃO UNIFICADA ESPACIAL (camadas verticais)
var navigation_enabled: bool = true
var navigable_elements: Array = []  # Lista unificada: slots, botões, filtros
var current_nav_index: int = 0  # Índice atual na lista unificada

# Camadas de navegação (organização espacial vertical)
var filter_indices: Array = []   # Índices dos filtros na lista unificada
var slot_indices: Array = []     # Índices dos slots na lista unificada
var button_indices: Array = []   # Índices dos botões na lista unificada

## Helper: Retorna o índice do slot atualmente selecionado (ou -1)
func get_selected_slot_index() -> int:
	if current_nav_index >= 0 and current_nav_index < navigable_elements.size():
		var elem = navigable_elements[current_nav_index]
		if elem.type == "slot":
			return elem.index
	return -1

## Helper: Seleciona um slot específico na navegação (usado para clicks)
func _select_slot_in_navigation(slot_index: int) -> void:
	remove_all_highlights()
	for i in range(navigable_elements.size()):
		if navigable_elements[i].type == "slot" and navigable_elements[i].index == slot_index:
			current_nav_index = i
			highlight_current_element()
			return


## Helper: Seleciona um equipamento na navegação (usado para clicks)
func _select_equipment_in_navigation(equip_type: ItemData.EquipmentSlot) -> void:
	remove_all_highlights()
	for i in range(navigable_elements.size()):
		if navigable_elements[i].type == "equipment" and navigable_elements[i].equip_type == equip_type:
			current_nav_index = i
			highlight_current_element()
			return


## Helper: Seleciona um filtro na navegação (usado para clicks)
func _select_filter_in_navigation(filter_type: int) -> void:
	remove_all_highlights()
	for i in range(navigable_elements.size()):
		if navigable_elements[i].type == "filter" and navigable_elements[i].filter_type == filter_type:
			current_nav_index = i
			highlight_current_element()
			return


## Helper: Seleciona um botão na navegação (usado para clicks)
func _select_button_in_navigation(button_name: String) -> void:
	remove_all_highlights()
	for i in range(navigable_elements.size()):
		if navigable_elements[i].type == "button" and navigable_elements[i].name == button_name:
			current_nav_index = i
			highlight_current_element()
			return

# Nós da UI
var panel: Panel
var grid_container: GridContainer
var slots_scroll_container: ScrollContainer  # Referência ao ScrollContainer dos slots
var equipment_panel: Panel
var close_button: Button
var split_button: Button
var use_button: Button
var drop_button: Button

# Filtros
var filter_buttons: Dictionary = {}
var filter_buttons_order: Array = []  # Ordem dos filtros para navegação
var current_filter: int = -1  # -1 = Todos, ou ItemData.ItemType

# Equipment slot UIs
var equipment_slot_uis: Dictionary = {}


func _ready() -> void:
	# Define layer alto para aparecer na frente de tudo
	layer = 150
	
	# Adiciona ao grupo para fácil acesso
	add_to_group("inventory_ui")
	
	# Busca o hotbar na cena
	await get_tree().process_frame
	hotbar_ui = get_tree().get_first_node_in_group("hotbar_ui")
	if hotbar_ui:
		print("[INVENTORY UI] 🔗 Hotbar encontrado para drag and drop")
	else:
		print("[INVENTORY UI] ⚠️ Hotbar não encontrado")
	
	# Esconde por padrão
	hide()
	
	# Define layer MUITO alto para ficar acima de TUDO
	layer = 100
	print("[INVENTORY UI] 🔝 CanvasLayer definido para 100 (acima de tudo)")
	
	create_ui()
	
	if inventory:
		setup_inventory(inventory)


## Input handler
func _input(event: InputEvent) -> void:
	# Toggle inventário
	if event.is_action_pressed("inventory"):
		toggle_inventory()
		get_viewport().set_input_as_handled()
		return
	
	# Navegação por teclado (apenas quando inventário aberto)
	if is_open and navigation_enabled:
		# Setas para navegar (UNIFICADO - sem modos separados)
		if event.is_action_pressed("navigate_up"):
			navigate_unified(-1, true)  # -1 = voltar, true = vertical
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("navigate_down"):
			navigate_unified(1, true)  # +1 = avançar, true = vertical
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("navigate_left"):
			navigate_unified(-1, false)  # -1 = voltar, false = horizontal
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("navigate_right"):
			navigate_unified(1, false)  # +1 = avançar, false = horizontal
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("navigate_select"):
			activate_current_element()
			get_viewport().set_input_as_handled()
		
		# Comandos globais (funcionam em qualquer modo)
		if event.is_action_pressed("inventory_stack"):
			stack_items()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("inventory_organize"):
			organize_inventory()
			get_viewport().set_input_as_handled()


## ═══════════════════════════════════════════════════════════════════
## SISTEMA DE NAVEGAÇÃO UNIFICADA (slots + botões + filtros)
## ═══════════════════════════════════════════════════════════════════

## Constrói a lista unificada de elementos navegáveis
func build_navigable_list() -> void:
	navigable_elements.clear()
	
	# 1. Adiciona FILTROS primeiro (topo)
	for i in range(filter_buttons_order.size()):
		var filter_type = filter_buttons_order[i]
		if filter_buttons.has(filter_type):
			navigable_elements.append({
				"type": "filter",
				"filter_type": filter_type,
				"object": filter_buttons[filter_type]
			})
	
	# 2. Adiciona todos os SLOTS do inventário (meio)
	for i in range(slot_uis.size()):
		navigable_elements.append({
			"type": "slot",
			"index": i,
			"object": slot_uis[i]
		})
	
	# 3. Adiciona EQUIPAMENTOS (lateral direita - mesma altura dos slots)
	# Ordem: Cabeça, Peito, Pernas, Botas, Luvas, Anel, Amuleto, Armas
	var equipment_order = [
		ItemData.EquipmentSlot.HEAD,
		ItemData.EquipmentSlot.CHEST,
		ItemData.EquipmentSlot.LEGS,
		ItemData.EquipmentSlot.BOOTS,
		ItemData.EquipmentSlot.GLOVES,
		ItemData.EquipmentSlot.RING,
		ItemData.EquipmentSlot.AMULET,
		ItemData.EquipmentSlot.WEAPON_PRIMARY,
		ItemData.EquipmentSlot.WEAPON_SECONDARY
	]
	
	for equip_type in equipment_order:
		if equipment_slot_uis.has(equip_type):
			navigable_elements.append({
				"type": "equipment",
				"equip_type": equip_type,
				"object": equipment_slot_uis[equip_type]
			})
	
	# 4. Adiciona BOTÕES de ação no final (baixo)
	var action_buttons = [
		{"button": use_button, "name": "use"},
		{"button": split_button, "name": "split"},
		{"button": drop_button, "name": "drop"}
	]
	
	var buttons_added = 0
	for btn_data in action_buttons:
		if btn_data.button:
			navigable_elements.append({
				"type": "button",
				"name": btn_data.name,
				"object": btn_data.button
			})
			buttons_added += 1
	
	print("[INVENTORY UI] 🗺️ Lista de navegação construída: %d elementos" % navigable_elements.size())
	print("[INVENTORY UI]    - Filtros: %d" % filter_buttons_order.size())
	print("[INVENTORY UI]    - Slots: %d" % slot_uis.size())
	print("[INVENTORY UI]    - Equipamentos: %d" % equipment_slot_uis.size())
	print("[INVENTORY UI]    - Botões: %d" % buttons_added)


## Navegação unificada - sistema de CAMADAS VERTICAIS + Equipamentos laterais
## Camadas: Filtros (topo) → Slots (meio - com equipamentos na lateral) → Botões (baixo)
## Setas horizontais (←→): navegam DENTRO da camada atual
## Setas verticais (↑↓): mudam de camada (só sai dos slots pelas bordas)
## Equipamentos: Acessíveis da última coluna dos slots com → (e vice-versa com ←)
func navigate_unified(direction: int, is_vertical: bool) -> void:
	if navigable_elements.is_empty():
		build_navigable_list()
		if navigable_elements.is_empty():
			return
	
	# Remove highlight do elemento atual
	remove_all_highlights()
	
	var current_elem = navigable_elements[current_nav_index]
	
	# ═══ NAVEGAÇÃO VERTICAL (↑↓) - Muda de camada ═══
	if is_vertical:
		match current_elem.type:
			"filter":
				# Está nos FILTROS (topo)
				if direction > 0:  # ↓ Para baixo: vai para SLOTS (primeira linha)
					_go_to_first_slot()
				else:  # ↑ Para cima: fica nos filtros (wrap horizontal)
					_navigate_within_layer("filter", direction)
			
			"slot":
				# Está nos SLOTS (meio) - navegação em GRID
				var slot_index = current_elem.index
				var current_col = slot_index % grid_columns
				var current_row = int(slot_index / grid_columns)
				var new_slot_index = slot_index + (direction * grid_columns)
				
				# Verifica se vai sair do grid
				if new_slot_index >= 0 and new_slot_index < slot_uis.size():
					# Ainda dentro dos slots - navega normalmente
					var new_row = int(new_slot_index / grid_columns)
					print("[INVENTORY UI] 🧭 Navegação vertical: slot %d (linha %d) → slot %d (linha %d)" % [slot_index, current_row, new_slot_index, new_row])
					_select_slot_by_index(new_slot_index)
				else:
					# Saiu do grid - muda de camada
					if direction > 0:  # ↓ Para baixo: vai para BOTÕES
						print("[INVENTORY UI] 🧭 Navegação vertical: slot %d → BOTÕES (saiu do grid)" % slot_index)
						_go_to_first_button()
					else:  # ↑ Para cima: vai para FILTROS (mesma coluna se possível)
						print("[INVENTORY UI] 🧭 Navegação vertical: slot %d → FILTROS (saiu do grid)" % slot_index)
						_go_to_filter_at_column(current_col)
			
			"equipment":
				# Está nos EQUIPAMENTOS (lateral) - navegação vertical dentro dos equipamentos
				_navigate_within_layer("equipment", direction)
			
			"button":
				# Está nos BOTÕES (baixo)
				if direction > 0:  # ↓ Para baixo: fica nos botões (wrap horizontal)
					_navigate_within_layer("button", direction)
				else:  # ↑ Para cima: vai para SLOTS (última linha)
					_go_to_last_slot_row()
	
	# ═══ NAVEGAÇÃO HORIZONTAL (←→) - Dentro da camada atual ═══
	else:
		match current_elem.type:
			"filter":
				# Navega entre filtros horizontalmente
				_navigate_within_layer("filter", direction)
			
			"slot":
				# Navega entre slots horizontalmente (mesma linha)
				var slot_index = current_elem.index
				var current_row = slot_index / grid_columns
				var current_col = slot_index % grid_columns
				
				# Se está na última coluna e aperta →, vai para EQUIPAMENTOS
				if direction > 0 and current_col == grid_columns - 1:
					_go_to_first_equipment()
				# Se está na primeira coluna e aperta ←, faz wrap para última
				elif direction < 0 and current_col == 0:
					var new_col = grid_columns - 1
					var new_slot_index = (current_row * grid_columns) + new_col
					if new_slot_index < slot_uis.size():
						_select_slot_by_index(new_slot_index)
				# Navegação normal dentro do grid
				else:
					var new_col = current_col + direction
					var new_slot_index = (current_row * grid_columns) + new_col
					if new_slot_index < slot_uis.size():
						_select_slot_by_index(new_slot_index)
			
			"equipment":
				# Se está em equipamento e aperta ←, volta para slots (última coluna)
				if direction < 0:
					_go_to_last_column_slots()
				# Se aperta → dentro dos equipamentos, faz wrap vertical
				else:
					_navigate_within_layer("equipment", direction)
			
			"button":
				# Navega entre botões horizontalmente
				_navigate_within_layer("button", direction)
	
	# Aplica highlight no novo elemento
	highlight_current_element()


## Helper: Navega dentro da mesma camada (filtros ou botões)
func _navigate_within_layer(layer_type: String, direction: int) -> void:
	var layer_elements = []
	for i in range(navigable_elements.size()):
		if navigable_elements[i].type == layer_type:
			layer_elements.append(i)
	
	if layer_elements.is_empty():
		return
	
	# Encontra posição atual na camada
	var current_pos = layer_elements.find(current_nav_index)
	if current_pos == -1:
		current_nav_index = layer_elements[0]
		return
	
	# Navega com wrap
	var new_pos = (current_pos + direction) % layer_elements.size()
	if new_pos < 0:
		new_pos = layer_elements.size() + new_pos
	current_nav_index = layer_elements[new_pos]


## Helper: Vai para o primeiro slot
func _go_to_first_slot() -> void:
	for i in range(navigable_elements.size()):
		if navigable_elements[i].type == "slot" and navigable_elements[i].index == 0:
			current_nav_index = i
			return


## Helper: Vai para a última linha de slots
func _go_to_last_slot_row() -> void:
	var last_row_start: int = int(floor(float(slot_uis.size() - 1) / float(grid_columns))) * grid_columns
	_select_slot_by_index(last_row_start)


## Helper: Vai para o primeiro botão
func _go_to_first_button() -> void:
	for i in range(navigable_elements.size()):
		if navigable_elements[i].type == "button":
			current_nav_index = i
			return
	# Se não tem botões, vai para primeiro filtro
	_go_to_first_filter()


## Helper: Vai para filtro na coluna especificada (ou primeiro)
func _go_to_filter_at_column(column: int) -> void:
	var available_filters = []
	for i in range(navigable_elements.size()):
		if navigable_elements[i].type == "filter":
			available_filters.append(i)
	
	if available_filters.is_empty():
		return
	
	# Tenta manter mesma coluna, senão usa primeira
	var target_index = min(column, available_filters.size() - 1)
	current_nav_index = available_filters[target_index]


## Helper: Vai para o primeiro filtro
func _go_to_first_filter() -> void:
	for i in range(navigable_elements.size()):
		if navigable_elements[i].type == "filter":
			current_nav_index = i
			return


## Helper: Seleciona slot por índice (atualiza current_nav_index)
func _select_slot_by_index(slot_index: int) -> void:
	for i in range(navigable_elements.size()):
		if navigable_elements[i].type == "slot" and navigable_elements[i].index == slot_index:
			current_nav_index = i
			return


## Helper: Vai para o primeiro equipamento
func _go_to_first_equipment() -> void:
	for i in range(navigable_elements.size()):
		if navigable_elements[i].type == "equipment":
			current_nav_index = i
			print("[INVENTORY UI] 🎯 Indo para equipamentos")
			return


## Helper: Vai para a última coluna dos slots (volta dos equipamentos)
func _go_to_last_column_slots() -> void:
	var last_col = grid_columns - 1
	# Tenta encontrar um slot na última coluna (qualquer linha)
	for i in range(navigable_elements.size()):
		if navigable_elements[i].type == "slot":
			var slot_idx = navigable_elements[i].index
			if slot_idx % grid_columns == last_col:
				current_nav_index = i
				print("[INVENTORY UI] 🎯 Voltando para slots (última coluna)")
				return
	# Fallback: vai para o último slot
	_select_slot_by_index(slot_uis.size() - 1)


## Ativa o elemento atualmente selecionado
func activate_current_element() -> void:
	if current_nav_index < 0 or current_nav_index >= navigable_elements.size():
		return
	
	var elem = navigable_elements[current_nav_index]
	
	match elem.type:
		"slot":
			# Usa item no slot
			var item = inventory.get_item_at(elem.index)
			if item:
				print("[INVENTORY UI] ✅ Usando item: %s (slot %d)" % [item.item_name, elem.index])
				inventory.use_item_at(elem.index)
				await get_tree().process_frame
				build_navigable_list()  # Reconstrói lista (botões podem mudar)
				highlight_current_element()
			else:
				print("[INVENTORY UI] ⚠️ Slot %d vazio" % elem.index)
		
		"button":
			# Ativa botão
			print("[INVENTORY UI] ✅ Ativando botão: %s" % elem.name)
			elem.object.emit_signal("pressed")
		
		"filter":
			# Ativa filtro
			print("[INVENTORY UI] ✅ Ativando filtro: %s" % elem.filter_type)
			_on_filter_changed(elem.filter_type)
		
		"equipment":
			# Seleciona ou usa o equipamento
			print("[INVENTORY UI] ✅ Interagindo com equipamento: %s" % elem.equip_type)
			# Aqui você pode adicionar lógica específica para equipamentos
			# Por exemplo: desequipar, trocar com item do inventário, etc.


## Destaca o elemento atual
func highlight_current_element() -> void:
	if current_nav_index < 0 or current_nav_index >= navigable_elements.size():
		return
	
	var elem = navigable_elements[current_nav_index]
	
	match elem.type:
		"slot":
			elem.object.set_highlighted(true)
			_ensure_slot_visible(elem.index)  # Garante que o slot está visível
			print("[INVENTORY UI] 🎯 Slot %d selecionado" % elem.index)
		
		"button":
			# Botões usam borda amarela customizada
			var style = StyleBoxFlat.new()
			style.bg_color = Color(0.2, 0.2, 0.2, 1.0)
			style.border_color = Color(1.0, 1.0, 0.0, 1.0)  # Amarelo
			style.border_width_left = 2
			style.border_width_right = 2
			style.border_width_top = 2
			style.border_width_bottom = 2
			style.corner_radius_top_left = 4
			style.corner_radius_top_right = 4
			style.corner_radius_bottom_left = 4
			style.corner_radius_bottom_right = 4
			elem.object.add_theme_stylebox_override("normal", style)
			elem.object.add_theme_stylebox_override("hover", style)
			elem.object.add_theme_stylebox_override("pressed", style)
			elem.object.add_theme_stylebox_override("disabled", style)
			print("[INVENTORY UI] 🎯 Botão '%s' selecionado" % elem.name)
		
		"filter":
			# Filtros usam modulate (são botões normais)
			elem.object.modulate = Color(1.5, 1.5, 0.5)
			print("[INVENTORY UI] 🎯 Filtro '%s' selecionado" % elem.filter_type)
		
		"equipment":
			# Equipamentos usam borda amarela como os slots
			if elem.object.has_method("set_highlighted"):
				elem.object.set_highlighted(true)
			else:
				# Fallback: usa modulate se não tiver o método
				elem.object.modulate = Color(1.5, 1.5, 0.5)
			print("[INVENTORY UI] 🎯 Equipamento '%s' selecionado" % elem.equip_type)


## Garante que um slot está visível na área de scroll
func _ensure_slot_visible(slot_index: int) -> void:
	if not slots_scroll_container or slot_index >= slot_uis.size():
		return
	
	var slot_ui = slot_uis[slot_index]
	if not slot_ui:
		return
	
	# Chama depois que o layout for atualizado
	_do_scroll_to_slot.call_deferred(slot_index)


## Realiza o scroll para o slot (chamado via deferred)
func _do_scroll_to_slot(slot_index: int) -> void:
	if not slots_scroll_container or slot_index >= slot_uis.size():
		print("[INVENTORY UI] ⚠️ Scroll cancelado: scroll_container=%s, slot_index=%d/%d" % [slots_scroll_container != null, slot_index, slot_uis.size()])
		return
	
	var slot_ui = slot_uis[slot_index]
	if not slot_ui:
		print("[INVENTORY UI] ⚠️ Scroll cancelado: slot_ui NULL para index %d" % slot_index)
		return
	
	# Calcula a posição do slot no grid (linha e coluna)
	var row: int = int(float(slot_index) / float(grid_columns))
	var col: int = slot_index % grid_columns
	
	# Separações e dimensões
	var v_sep = grid_container.get_theme_constant("v_separation")
	var h_sep = grid_container.get_theme_constant("h_separation")
	var slot_height = slot_ui.slot_size.y + v_sep
	var slot_width = slot_ui.slot_size.x + h_sep
	
	# Posições X e Y do slot
	var slot_x = col * slot_width
	var slot_y = row * slot_height
	
	# Dimensões e scroll atual (vertical e horizontal)
	var scroll_height = slots_scroll_container.size.y
	var scroll_width = slots_scroll_container.size.x
	var current_scroll_v = slots_scroll_container.scroll_vertical
	var current_scroll_h = slots_scroll_container.scroll_horizontal
	var max_scroll_v = slots_scroll_container.get_v_scroll_bar().max_value
	var max_scroll_h = slots_scroll_container.get_h_scroll_bar().max_value
	
	print("[INVENTORY UI] 📜 Scroll check:")
	print("   Slot %d (linha %d, coluna %d)" % [slot_index, row, col])
	print("   Slot pos: X=%.1f Y=%.1f | Size: %.1fx%.1f" % [slot_x, slot_y, slot_width, slot_height])
	print("   Scroll V: %.1f/%.1f | H: %.1f/%.1f" % [current_scroll_v, max_scroll_v, current_scroll_h, max_scroll_h])
	print("   Visible area: %.1fx%.1f" % [scroll_width, scroll_height])
	
	# Margem para scroll mais agressivo
	var margin = 50.0
	
	# ═══ SCROLL VERTICAL ═══
	if slot_y < current_scroll_v + margin:
		var new_scroll = max(0, slot_y - margin)
		slots_scroll_container.scroll_vertical = new_scroll
		print("   ⬆️ SCROLL VERTICAL: %.1f (slot acima)" % new_scroll)
	elif slot_y + slot_height > current_scroll_v + scroll_height - margin:
		var new_scroll = slot_y + slot_height - scroll_height + margin
		new_scroll = min(new_scroll, max_scroll_v)
		slots_scroll_container.scroll_vertical = new_scroll
		print("   ⬇️ SCROLL VERTICAL: %.1f (slot abaixo)" % new_scroll)
	
	# ═══ SCROLL HORIZONTAL ═══
	if slot_x < current_scroll_h + margin:
		var new_scroll = max(0, slot_x - margin)
		slots_scroll_container.scroll_horizontal = new_scroll
		print("   ⬅️ SCROLL HORIZONTAL: %.1f (slot à esquerda)" % new_scroll)
	elif slot_x + slot_width > current_scroll_h + scroll_width - margin:
		var new_scroll = slot_x + slot_width - scroll_width + margin
		new_scroll = min(new_scroll, max_scroll_h)
		slots_scroll_container.scroll_horizontal = new_scroll
		print("   ➡️ SCROLL HORIZONTAL: %.1f (slot à direita)" % new_scroll)


## Remove todos os highlights
func remove_all_highlights() -> void:
	# Remove de slots
	for slot_ui in slot_uis:
		slot_ui.set_highlighted(false)
	
	# Remove de equipamentos
	for equip_ui in equipment_slot_uis.values():
		if equip_ui and equip_ui.has_method("set_highlighted"):
			equip_ui.set_highlighted(false)
		elif equip_ui:
			equip_ui.modulate = Color.WHITE
	
	# Remove de botões (remove overrides de stylebox)
	if use_button:
		use_button.remove_theme_stylebox_override("normal")
		use_button.remove_theme_stylebox_override("hover")
		use_button.remove_theme_stylebox_override("pressed")
		use_button.remove_theme_stylebox_override("disabled")
	if split_button:
		split_button.remove_theme_stylebox_override("normal")
		split_button.remove_theme_stylebox_override("hover")
		split_button.remove_theme_stylebox_override("pressed")
		split_button.remove_theme_stylebox_override("disabled")
	if drop_button:
		drop_button.remove_theme_stylebox_override("normal")
		drop_button.remove_theme_stylebox_override("hover")
		drop_button.remove_theme_stylebox_override("pressed")
		drop_button.remove_theme_stylebox_override("disabled")
	
	# Remove de filtros
	for btn in filter_buttons.values():
		if btn:
			btn.modulate = Color.WHITE


## ═══════════════════════════════════════════════════════════════════
## FUNÇÕES ANTIGAS (mantidas para compatibilidade)
## ═══════════════════════════════════════════════════════════════════

## Atualiza o highlight do slot selecionado (versão antiga)
func refresh_highlight() -> void:
	highlight_current_element()


## Remove highlight dos botões (versão antiga)
func remove_button_highlights() -> void:
	if use_button:
		use_button.modulate = Color.WHITE
	if split_button:
		split_button.modulate = Color.WHITE
	if drop_button:
		drop_button.modulate = Color.WHITE


## Remove highlight dos filtros (versão antiga)
func remove_filter_highlights() -> void:
	for btn in filter_buttons.values():
		if btn:
			btn.modulate = Color.WHITE


## ═══════════════════════════════════════════════════════════════════


## Atualiza a UI de todos os slots
func refresh_ui() -> void:
	for i in range(slot_uis.size()):
		if i < inventory.slots.size():
			slot_uis[i].set_inventory_slot(inventory.slots[i])


## Agrupa itens stackáveis do mesmo tipo
func stack_items() -> void:
	print("[INVENTORY UI] 📦 Agrupando itens stackáveis...")
	
	for i in range(inventory.slots.size()):
		var slot_i = inventory.slots[i]
		if slot_i.is_empty() or not slot_i.item.is_stackable:
			continue
		
		# Procura outros slots com o mesmo item
		for j in range(i + 1, inventory.slots.size()):
			var slot_j = inventory.slots[j]
			if slot_j.is_empty():
				continue
			
			# Se é o mesmo item e stackável
			if slot_j.item.item_id == slot_i.item.item_id and slot_j.item.is_stackable:
				var space_available = slot_i.item.max_stack_size - slot_i.quantity
				
				if space_available > 0:
					var amount_to_move = min(slot_j.quantity, space_available)
					slot_i.quantity += amount_to_move
					slot_j.quantity -= amount_to_move
					
					if slot_j.quantity <= 0:
						slot_j.clear()
					
					print("[INVENTORY UI]    Agrupado %d x %s" % [amount_to_move, slot_i.item.item_name])
	
	refresh_ui()
	refresh_highlight()
	print("[INVENTORY UI] ✅ Agrupamento concluído!")


## Organiza o inventário (remove espaços vazios)
func organize_inventory() -> void:
	print("[INVENTORY UI] 🗂️ Organizando inventário...")
	
	var non_empty_slots: Array = []
	
	# Coleta todos os slots não vazios
	for slot in inventory.slots:
		if not slot.is_empty():
			non_empty_slots.append({
				"item": slot.item,
				"quantity": slot.quantity
			})
	
	# Limpa todos os slots
	for slot in inventory.slots:
		slot.clear()
	
	# Recoloca os itens nos primeiros slots
	for i in range(non_empty_slots.size()):
		inventory.slots[i].item = non_empty_slots[i].item
		inventory.slots[i].quantity = non_empty_slots[i].quantity
	
	refresh_ui()
	
	# Reconstrói lista de navegação e seleciona primeiro elemento
	build_navigable_list()
	current_nav_index = 0
	highlight_current_element()
	
	print("[INVENTORY UI] ✅ Inventário organizado!")


## Cria toda a estrutura da UI
func create_ui() -> void:
	print("[INVENTORY UI] 🎨 Criando UI do inventário...")
	
	# Panel principal
	panel = Panel.new()
	panel.name = "InventoryPanel"
	panel.custom_minimum_size = Vector2(450, 500)
	
	# 🎯 CENTRALIZA O PAINEL!
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	panel.position = Vector2(-225, -250)  # Offset para centralizar (metade do tamanho)
	
	panel.mouse_filter = Control.MOUSE_FILTER_STOP  # STOP para capturar eventos!
	add_child(panel)
	
	print("[INVENTORY UI]    Panel mouse_filter: STOP (captura eventos!)")
	print("[INVENTORY UI]    Panel position: %s" % panel.position)
	print("[INVENTORY UI]    Panel size: %s" % panel.custom_minimum_size)
	
	# VBox para organizar conteúdo
	var vbox = VBoxContainer.new()
	vbox.anchor_right = 1
	vbox.anchor_bottom = 1
	vbox.mouse_filter = Control.MOUSE_FILTER_PASS  # Passa eventos para os filhos
	panel.add_child(vbox)
	
	# Header com título e botão de fechar
	var header = HBoxContainer.new()
	vbox.add_child(header)
	
	var title = Label.new()
	title.text = "Inventário"
	title.add_theme_font_size_override("font_size", 20)
	header.add_child(title)
	
	header.add_child(Control.new())  # Spacer
	header.get_child(1).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	close_button = Button.new()
	close_button.text = "X"
	close_button.custom_minimum_size = Vector2(30, 30)
	close_button.focus_mode = Control.FOCUS_NONE  # Desabilita navegação por teclado (WASD)
	close_button.pressed.connect(close_inventory)
	header.add_child(close_button)
	
	# Separador
	var separator1 = HSeparator.new()
	vbox.add_child(separator1)
	
	# === FILTROS ===
	var filters_hbox = HBoxContainer.new()
	filters_hbox.add_theme_constant_override("separation", 4)
	filters_hbox.mouse_filter = Control.MOUSE_FILTER_PASS
	vbox.add_child(filters_hbox)
	
	var filter_label = Label.new()
	filter_label.text = "Filtrar:"
	filters_hbox.add_child(filter_label)
	
	# Botão "Todos"
	var all_button = Button.new()
	all_button.text = "Todos"
	all_button.toggle_mode = true
	all_button.button_pressed = true
	all_button.focus_mode = Control.FOCUS_NONE  # Desabilita navegação por teclado (WASD)
	all_button.pressed.connect(_on_filter_changed.bind(-1))
	filters_hbox.add_child(all_button)
	filter_buttons[-1] = all_button
	filter_buttons_order.append(-1)  # Adiciona à ordem
	
	# Botões para cada tipo
	var filter_types = [
		["Consumíveis", ItemData.ItemType.CONSUMABLE],
		["Equipamentos", ItemData.ItemType.EQUIPMENT],
		["Armas", ItemData.ItemType.WEAPON],
		["Materiais", ItemData.ItemType.MATERIAL],
	]
	
	for filter_data in filter_types:
		var btn = Button.new()
		btn.text = filter_data[0]
		btn.toggle_mode = true
		btn.focus_mode = Control.FOCUS_NONE  # Desabilita navegação por teclado (WASD)
		btn.pressed.connect(_on_filter_changed.bind(filter_data[1]))
		filters_hbox.add_child(btn)
		filter_buttons[filter_data[1]] = btn
		filter_buttons_order.append(filter_data[1])  # Adiciona à ordem
	
	var separator_filter = HSeparator.new()
	vbox.add_child(separator_filter)
	
	# HBox para slots principais e equipamentos
	var hbox_main = HBoxContainer.new()
	hbox_main.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox_main.mouse_filter = Control.MOUSE_FILTER_PASS
	vbox.add_child(hbox_main)
	
	# === GRID DE SLOTS PRINCIPAIS ===
	var slots_vbox = VBoxContainer.new()
	slots_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slots_vbox.mouse_filter = Control.MOUSE_FILTER_PASS
	hbox_main.add_child(slots_vbox)
	
	var slots_label = Label.new()
	slots_label.text = "Itens"
	slots_label.add_theme_font_size_override("font_size", 16)
	slots_vbox.add_child(slots_label)
	
	# ScrollContainer para os slots
	slots_scroll_container = ScrollContainer.new()
	slots_scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	slots_scroll_container.mouse_filter = Control.MOUSE_FILTER_PASS  # Passa eventos para os filhos
	slots_vbox.add_child(slots_scroll_container)
	
	grid_container = GridContainer.new()
	grid_container.columns = grid_columns
	grid_container.add_theme_constant_override("h_separation", slot_spacing)
	grid_container.add_theme_constant_override("v_separation", slot_spacing)
	grid_container.mouse_filter = Control.MOUSE_FILTER_PASS  # Passa eventos para os filhos
	slots_scroll_container.add_child(grid_container)
	
	# Botões de ação
	var actions_hbox = HBoxContainer.new()
	actions_hbox.add_theme_constant_override("separation", 4)
	actions_hbox.mouse_filter = Control.MOUSE_FILTER_PASS
	slots_vbox.add_child(actions_hbox)
	
	use_button = Button.new()
	use_button.text = "Usar"
	use_button.disabled = true
	use_button.focus_mode = Control.FOCUS_NONE  # Desabilita navegação por teclado (WASD)
	use_button.pressed.connect(_on_use_button_pressed)
	actions_hbox.add_child(use_button)
	
	split_button = Button.new()
	split_button.text = "Dividir"
	split_button.disabled = true
	split_button.focus_mode = Control.FOCUS_NONE  # Desabilita navegação por teclado (WASD)
	split_button.pressed.connect(_on_split_button_pressed)
	actions_hbox.add_child(split_button)
	
	drop_button = Button.new()
	drop_button.text = "Dropar"
	drop_button.disabled = true
	drop_button.focus_mode = Control.FOCUS_NONE  # Desabilita navegação por teclado (WASD)
	drop_button.pressed.connect(_on_drop_button_pressed)
	actions_hbox.add_child(drop_button)
	
	# === PANEL DE EQUIPAMENTOS ===
	equipment_panel = Panel.new()
	equipment_panel.custom_minimum_size = Vector2(150, 0)
	hbox_main.add_child(equipment_panel)
	
	var equip_vbox = VBoxContainer.new()
	equip_vbox.anchor_right = 1
	equip_vbox.anchor_bottom = 1
	equip_vbox.add_theme_constant_override("separation", 8)
	equipment_panel.add_child(equip_vbox)
	
	var equip_label = Label.new()
	equip_label.text = "Equipamentos"
	equip_label.add_theme_font_size_override("font_size", 16)
	equip_vbox.add_child(equip_label)
	
	# Cria slots de equipamento
	create_equipment_slots(equip_vbox)


## Cria os slots de equipamento
func create_equipment_slots(parent: VBoxContainer) -> void:
	var equipment_types = [
		ItemData.EquipmentSlot.HEAD,
		ItemData.EquipmentSlot.CHEST,
		ItemData.EquipmentSlot.LEGS,
		ItemData.EquipmentSlot.BOOTS,
		ItemData.EquipmentSlot.GLOVES,
		ItemData.EquipmentSlot.RING,
		ItemData.EquipmentSlot.AMULET,
		ItemData.EquipmentSlot.WEAPON_PRIMARY,
		ItemData.EquipmentSlot.WEAPON_SECONDARY,
	]
	
	for slot_type in equipment_types:
		var hbox = HBoxContainer.new()
		parent.add_child(hbox)
		
		var label = Label.new()
		label.text = ItemData.EquipmentSlot.keys()[slot_type]
		label.custom_minimum_size = Vector2(80, 0)
		hbox.add_child(label)
		
		var slot_ui = InventorySlotUI.new()
		slot_ui.slot_size = Vector2(48, 48)
		slot_ui.slot_clicked.connect(_on_equipment_slot_clicked.bind(slot_type))
		hbox.add_child(slot_ui)
		
		equipment_slot_uis[slot_type] = slot_ui


## Configura o inventário
func setup_inventory(inv: Inventory) -> void:
	print("\n[INVENTORY UI] 🔧 Configurando inventário...")
	inventory = inv
	
	if not inventory:
		print("[INVENTORY UI] ❌ Inventário é NULL!")
		return
	
	if not grid_container:
		print("[INVENTORY UI] ⚠️ Grid container ainda não foi criado - aguardando...")
		# Tenta novamente após um frame
		await get_tree().process_frame
		if not grid_container:
			print("[INVENTORY UI] ❌ Grid container ainda não existe após wait!")
			return
	
	print("[INVENTORY UI]    Slots: %d" % inventory.inventory_size)
	
	# Limpa slots existentes
	for child in grid_container.get_children():
		child.queue_free()
	slot_uis.clear()
	
	# Cria UI para cada slot
	for i in range(inventory.slots.size()):
		var slot_ui = InventorySlotUI.new()
		slot_ui.slot_index = i
		slot_ui.slot_size = slot_size
		slot_ui.set_inventory_slot(inventory.slots[i])
		
		# Conecta sinais
		slot_ui.slot_clicked.connect(_on_slot_clicked)
		slot_ui.slot_double_clicked.connect(_on_slot_double_clicked)
		slot_ui.slot_right_clicked.connect(_on_slot_right_clicked)
		slot_ui.drag_started.connect(_on_slot_drag_started)
		slot_ui.drag_ended.connect(_on_slot_drag_ended)
		
		print("[INVENTORY UI]    Slot %d criado e conectado" % i)
		
		grid_container.add_child(slot_ui)
		slot_uis.append(slot_ui)
	
	# Conecta signals do inventário
	if not inventory.inventory_changed.is_connected(_on_inventory_changed):
		inventory.inventory_changed.connect(_on_inventory_changed)
	if not inventory.equipment_changed.is_connected(_on_equipment_changed):
		inventory.equipment_changed.connect(_on_equipment_changed)
	
	update_equipment_display()


## Abre o inventário
func open_inventory() -> void:
	print("[INVENTORY UI] 📂 Abrindo inventário...")
	is_open = true
	show()
	
	# Reconstrói lista de navegação e destaca primeiro elemento
	build_navigable_list()
	current_nav_index = 0
	highlight_current_element()
	
	if current_filter != -1:
		apply_filter()
	print("[INVENTORY UI] ✅ Inventário aberto")


## Fecha o inventário
func close_inventory() -> void:
	print("[INVENTORY UI] 📁 Fechando inventário...")
	is_open = false
	hide()
	
	# Remove todos os highlights
	remove_all_highlights()
	
	# Reseta navegação
	current_nav_index = 0
	navigable_elements.clear()
	
	update_action_buttons()
	print("[INVENTORY UI] ✅ Inventário fechado")


## Toggle do inventário
func toggle_inventory() -> void:
	print("[INVENTORY UI] 🔄 Toggle inventário chamado - is_open atual: %s" % is_open)
	if is_open:
		close_inventory()
	else:
		open_inventory()


## Callback quando um slot é clicado
func _on_slot_clicked(slot_index: int, mouse_button: int) -> void:
	print("\n[INVENTORY UI] 🖱️ CALLBACK _on_slot_clicked chamado!")
	print("[INVENTORY UI]    Slot: %d" % slot_index)
	print("[INVENTORY UI]    Botão: %d" % mouse_button)
	
	if not inventory:
		print("[INVENTORY UI] ❌ Inventory é NULL!")
		return
	
	var slot = inventory.slots[slot_index]
	print("[INVENTORY UI]    Slot vazio? %s" % slot.is_empty())
	
	# Shift + Click = Split
	if Input.is_key_pressed(KEY_SHIFT) and mouse_button == MOUSE_BUTTON_LEFT:
		print("[INVENTORY UI] ✂️ Shift+Click detectado - dividindo slot")
		inventory.split_slot(slot_index)
		return
	
	# Click esquerdo = Usa/equipa diretamente (navegação por teclado é separada)
	if mouse_button == MOUSE_BUTTON_LEFT:
		print("[INVENTORY UI] 👆 Click esquerdo no slot %d" % slot_index)
		if not slot.is_empty():
			if slot.item_data.is_usable():
				print("[INVENTORY UI] ✅ Usando item do slot %d" % slot_index)
				inventory.use_item(slot_index)
			elif slot.item_data.is_equippable:
				print("[INVENTORY UI] ✅ Equipando item do slot %d" % slot_index)
				inventory.equip_item(slot_index)
		
		# Atualiza navegação para este slot (já aplica highlight)
		_select_slot_in_navigation(slot_index)
		update_action_buttons()



## Callback quando slot recebe double-click
func _on_slot_double_clicked(slot_index: int) -> void:
	print("\n[INVENTORY UI] ⚡ DOUBLE-CLICK detectado no slot %d" % slot_index)
	
	if not inventory:
		return
	
	# Ignora double-click se estiver arrastando
	if dragging_from_slot != -1:
		print("[INVENTORY UI] ⚠️ Ignorando double-click durante drag")
		return
	
	# Verifica se o slot específico está sendo arrastado
	if slot_index >= 0 and slot_index < slot_uis.size() and slot_uis[slot_index].is_dragging:
		print("[INVENTORY UI] ⚠️ Ignorando double-click - slot está sendo arrastado")
		return
	
	var slot = inventory.slots[slot_index]
	if slot.is_empty():
		print("[INVENTORY UI] ❌ Slot vazio")
		return
	
	print("[INVENTORY UI]    Item: %s" % slot.item_data.item_name)
	
	# Double-click = usar/equipar direto
	if slot.item_data.is_usable():
		print("[INVENTORY UI] 🍷 Usando consumível...")
		inventory.use_item(slot_index)
	elif slot.item_data.is_equippable:
		print("[INVENTORY UI] 🎽 Equipando item...")
		inventory.equip_item(slot_index)
	else:
		print("[INVENTORY UI] ⚠️ Item não é usável nem equipável")


## Callback quando um slot é clicado com botão direito
func _on_slot_right_clicked(slot_index: int) -> void:
	if not inventory:
		return
	
	# Ignora right-click se estiver arrastando
	if dragging_from_slot != -1:
		return
	
	# Verifica se o slot específico está sendo arrastado
	if slot_index >= 0 and slot_index < slot_uis.size() and slot_uis[slot_index].is_dragging:
		return
	
	var slot = inventory.slots[slot_index]
	if slot.is_empty():
		return
	
	# Botão direito = ação rápida (mesmo que double-click)
	if slot.item_data.is_usable():
		inventory.use_item(slot_index)
	elif slot.item_data.is_equippable:
		inventory.equip_item(slot_index)


## Callback quando começa a arrastar um slot
func _on_slot_drag_started(slot_index: int) -> void:
	print("[INVENTORY UI] 🖱️ Drag iniciado no slot %d" % slot_index)
	dragging_from_slot = slot_index


## Callback quando termina de arrastar um slot
func _on_slot_drag_ended(target_slot_index: int) -> void:
	print("[INVENTORY UI] 🖱️ Drag finalizado - origem: %d, destino: %d" % [dragging_from_slot, target_slot_index])
	
	if dragging_from_slot == -1:
		return
	
	# Se arrastou para outro slot do inventário
	if target_slot_index >= 0 and target_slot_index < inventory.slots.size():
		if dragging_from_slot != target_slot_index:
			var from_slot = inventory.slots[dragging_from_slot]
			var to_slot = inventory.slots[target_slot_index]
			
			# Se ambos têm o mesmo item e são stackáveis, agrupa
			if not from_slot.is_empty() and not to_slot.is_empty():
				if from_slot.item.item_id == to_slot.item.item_id and from_slot.item.is_stackable:
					var space_available = to_slot.item.max_stack_size - to_slot.quantity
					
					if space_available > 0:
						var amount_to_move = min(from_slot.quantity, space_available)
						to_slot.quantity += amount_to_move
						from_slot.quantity -= amount_to_move
						
						if from_slot.quantity <= 0:
							from_slot.clear()
						
						print("[INVENTORY UI] 📦 Itens agrupados: %d x %s" % [amount_to_move, to_slot.item.item_name])
						refresh_ui()
						refresh_highlight()
						dragging_from_slot = -1
						return
			
			# Caso contrário, troca os itens
			inventory.swap_slots(dragging_from_slot, target_slot_index)
			print("[INVENTORY UI] 🔄 Items trocados entre slots %d e %d" % [dragging_from_slot, target_slot_index])
	
	dragging_from_slot = -1


## Adiciona item do inventário à hotbar (chamado quando arrasta para hotbar)
func add_inventory_item_to_hotbar(inventory_slot_index: int, hotbar_slot_index: int) -> void:
	if not hotbar_ui:
		print("[INVENTORY UI] ❌ Hotbar não encontrado!")
		return
	
	if inventory_slot_index < 0 or inventory_slot_index >= inventory.slots.size():
		print("[INVENTORY UI] ❌ Índice de inventário inválido: %d" % inventory_slot_index)
		return
	
	var slot = inventory.slots[inventory_slot_index]
	if slot.is_empty():
		print("[INVENTORY UI] ❌ Slot vazio - não pode adicionar à hotbar")
		return
	
	# Adiciona à hotbar
	hotbar_ui.add_to_hotbar(inventory_slot_index, hotbar_slot_index)
	print("[INVENTORY UI] ✅ Item adicionado à hotbar: inventário[%d] -> hotbar[%d]" % [inventory_slot_index, hotbar_slot_index])


## Destaca visualmente o slot selecionado (versão antiga - removida, usa highlight_current_element)
func highlight_selected_slot() -> void:
	# Esta função foi substituída por highlight_current_element()
	# Mantida apenas para compatibilidade
	highlight_current_element()


## Callback quando slot de equipamento é clicado
func _on_equipment_slot_clicked(_slot_index: int, mouse_button: int, equip_type: ItemData.EquipmentSlot) -> void:
	if not inventory:
		return
	
	if mouse_button == MOUSE_BUTTON_LEFT:
		# Atualiza navegação para este equipamento (já aplica highlight)
		_select_equipment_in_navigation(equip_type)
		inventory.unequip_item(equip_type)


## Atualiza display dos equipamentos
func update_equipment_display() -> void:
	if not inventory:
		return
	
	for equip_type in equipment_slot_uis.keys():
		var slot_ui = equipment_slot_uis[equip_type]
		var equipped_item = inventory.get_equipped_item(equip_type)
		
		# Cria um slot temporário para display
		var temp_slot = InventorySlot.new()
		if equipped_item:
			temp_slot.set_item(equipped_item, 1)
		
		slot_ui.set_inventory_slot(temp_slot)


## Callbacks de mudanças
func _on_inventory_changed() -> void:
	# UI já está conectada aos slots individuais
	pass


func _on_equipment_changed(_slot_type: ItemData.EquipmentSlot) -> void:
	update_equipment_display()


## Callback para mudança de filtro
func _on_filter_changed(filter_type: int) -> void:
	print("\n[INVENTORY UI] 🔍 Mudando filtro para: ", filter_type)
	
	# Atualiza navegação para este filtro (já aplica highlight)
	_select_filter_in_navigation(filter_type)
	
	# Desativa outros botões
	for btn_type in filter_buttons:
		filter_buttons[btn_type].button_pressed = (btn_type == filter_type)
	
	current_filter = filter_type
	apply_filter()
	
	var filter_name = "Todos" if filter_type == -1 else ItemData.ItemType.keys()[filter_type]
	print("[INVENTORY UI] ✅ Filtro aplicado: %s" % filter_name)


## Aplica o filtro atual aos slots
func apply_filter() -> void:
	if not inventory:
		print("[INVENTORY UI] ⚠️ Filtro: Inventário é NULL")
		return
	
	var visible_count = 0
	
	for i in range(slot_uis.size()):
		var slot_ui = slot_uis[i]
		var slot = inventory.slots[i]
		
		# Se filtro é "Todos" (-1) ou slot vazio, sempre mostra
		if current_filter == -1 or slot.is_empty():
			slot_ui.visible = true
			if not slot.is_empty():
				visible_count += 1
			continue
		
		# Mostra apenas se o tipo corresponde
		var should_show = (slot.item_data.item_type == current_filter)
		slot_ui.visible = should_show
		if should_show:
			visible_count += 1
	
	print("[INVENTORY UI]    Itens visíveis após filtro: %d" % visible_count)


## Callback para botão "Usar"
func _on_use_button_pressed() -> void:
	print("\n[INVENTORY UI] 🔘 Botão 'Usar' pressionado")
	
	# Atualiza navegação para este botão (já aplica highlight)
	_select_button_in_navigation("use")
	
	var selected_slot_index = get_selected_slot_index()
	if selected_slot_index == -1:
		print("[INVENTORY UI] ❌ Nenhum slot selecionado")
		return
	
	if not inventory:
		print("[INVENTORY UI] ❌ Inventário é NULL!")
		return
	
	print("[INVENTORY UI]    Slot selecionado: %d" % selected_slot_index)
	
	if inventory.use_item(selected_slot_index):
		print("[INVENTORY UI] ✅ Item usado com sucesso")
		update_action_buttons()
	else:
		print("[INVENTORY UI] ❌ Falha ao usar item")


## Callback para botão "Dividir"
func _on_split_button_pressed() -> void:
	# Atualiza navegação para este botão (já aplica highlight)
	_select_button_in_navigation("split")
	
	var selected_slot_index = get_selected_slot_index()
	if selected_slot_index == -1 or not inventory:
		return
	
	var slot = inventory.slots[selected_slot_index]
	if slot.is_empty() or slot.quantity <= 1:
		print("[INVENTORY UI] ❌ Não é possível dividir (quantidade: %d)" % slot.quantity)
		return
	
	print("[INVENTORY UI] ✂️ Dividindo %s (quantidade: %d)" % [slot.item_data.item_name, slot.quantity])
	
	var new_slot_index = inventory.split_slot(selected_slot_index)
	
	if new_slot_index >= 0:
		print("[INVENTORY UI] ✅ Item dividido! Novo slot: %d" % new_slot_index)
	else:
		print("[INVENTORY UI] ❌ Falha ao dividir - inventário pode estar cheio")
	
	update_action_buttons()


## Callback para botão "Dropar"
func _on_drop_button_pressed() -> void:
	# Atualiza navegação para este botão (já aplica highlight)
	_select_button_in_navigation("drop")
	
	var selected_slot_index = get_selected_slot_index()
	if selected_slot_index == -1 or not inventory:
		return
	
	var slot = inventory.slots[selected_slot_index]
	if slot.is_empty():
		return
	
	print("[INVENTORY UI] 📦 Dropando: %s x%d" % [slot.item_data.item_name, slot.quantity])
	
	# Encontra o player para dropar na posição dele
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("drop_item"):
		# Player tem função drop_item
		player.drop_item(slot.item_data, slot.quantity)
	else:
		print("[INVENTORY UI] ⚠️ Player não encontrado ou não tem função drop_item")
	
	# Remove do inventário
	slot.clear()
	update_action_buttons()


## Atualiza estado dos botões de ação
func update_action_buttons() -> void:
	# Verifica se os botões existem
	if not use_button or not split_button or not drop_button:
		return
	
	var selected_slot_index = get_selected_slot_index()
	if selected_slot_index == -1 or not inventory:
		use_button.disabled = true
		split_button.disabled = true
		drop_button.disabled = true
		return
	
	var slot = inventory.slots[selected_slot_index]
	
	if slot.is_empty():
		use_button.disabled = true
		split_button.disabled = true
		drop_button.disabled = true
		return
	
	# Usar: apenas consumíveis
	use_button.disabled = not slot.item_data.is_usable()
	
	# Dividir: apenas se quantidade > 1
	split_button.disabled = (slot.quantity <= 1)
	
	# Dropar: sempre disponível se tem item
	drop_button.disabled = false


## Verifica se o mouse está sobre a UI do inventário
func is_mouse_over_ui() -> bool:
	if not visible or not panel:
		return false
	
	var mouse_pos = get_viewport().get_mouse_position()
	var panel_rect = panel.get_global_rect()
	
	return panel_rect.has_point(mouse_pos)
