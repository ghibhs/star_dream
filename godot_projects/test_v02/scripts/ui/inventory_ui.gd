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

# Keyboard navigation
var selected_slot_index: int = 0
var navigation_enabled: bool = true
var focus_mode: String = "slots"  # "slots", "buttons", "filters"
var selected_button_index: int = 0
var selected_filter_index: int = 0

# Nós da UI
var panel: Panel
var grid_container: GridContainer
var equipment_panel: Panel
var close_button: Button
var split_button: Button
var use_button: Button
var drop_button: Button

# Filtros
var filter_buttons: Dictionary = {}
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
		# Tab para mudar entre modos de foco
		if event.is_action_pressed("ui_focus_next"):
			cycle_focus_mode()
			get_viewport().set_input_as_handled()
			return
		
		# Navegação baseada no modo de foco
		if focus_mode == "slots":
			if event.is_action_pressed("inventory_left"):
				navigate_slots(-1)
				get_viewport().set_input_as_handled()
			elif event.is_action_pressed("inventory_right"):
				navigate_slots(1)
				get_viewport().set_input_as_handled()
			elif event.is_action_pressed("inventory_up"):
				navigate_slots(-grid_columns)
				get_viewport().set_input_as_handled()
			elif event.is_action_pressed("inventory_down"):
				navigate_slots(grid_columns)
				get_viewport().set_input_as_handled()
			elif event.is_action_pressed("inventory_select"):
				select_current_slot()
				get_viewport().set_input_as_handled()
		
		elif focus_mode == "buttons":
			if event.is_action_pressed("inventory_left"):
				navigate_buttons(-1)
				get_viewport().set_input_as_handled()
			elif event.is_action_pressed("inventory_right"):
				navigate_buttons(1)
				get_viewport().set_input_as_handled()
			elif event.is_action_pressed("inventory_select"):
				activate_current_button()
				get_viewport().set_input_as_handled()
		
		elif focus_mode == "filters":
			if event.is_action_pressed("inventory_left"):
				navigate_filters(-1)
				get_viewport().set_input_as_handled()
			elif event.is_action_pressed("inventory_right"):
				navigate_filters(1)
				get_viewport().set_input_as_handled()
			elif event.is_action_pressed("inventory_select"):
				activate_current_filter()
				get_viewport().set_input_as_handled()
		
		# Comandos globais (funcionam em qualquer modo)
		if event.is_action_pressed("inventory_stack"):
			stack_items()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("inventory_organize"):
			organize_inventory()
			get_viewport().set_input_as_handled()


## Navega pelos slots do inventário
func navigate_slots(direction: int) -> void:
	if slot_uis.is_empty():
		return
	
	# Remove highlight do slot atual
	if selected_slot_index >= 0 and selected_slot_index < slot_uis.size():
		slot_uis[selected_slot_index].set_highlighted(false)
	
	# Calcula novo índice com wrap-around
	selected_slot_index = (selected_slot_index + direction) % slot_uis.size()
	if selected_slot_index < 0:
		selected_slot_index = slot_uis.size() + selected_slot_index
	
	# Aplica highlight no novo slot
	if selected_slot_index >= 0 and selected_slot_index < slot_uis.size():
		slot_uis[selected_slot_index].set_highlighted(true)
		print("[INVENTORY UI] 🎯 Navegando para slot %d" % selected_slot_index)


## Seleciona/usa o slot atual
func select_current_slot() -> void:
	if selected_slot_index < 0 or selected_slot_index >= slot_uis.size():
		return
	
	var item = inventory.get_item_at(selected_slot_index)
	
	if item:
		print("[INVENTORY UI] ✅ Usando item: %s" % item.item_name)
		inventory.use_item_at(selected_slot_index)
		# Mantém a seleção no mesmo slot após usar
		await get_tree().process_frame
		refresh_highlight()
	else:
		print("[INVENTORY UI] ⚠️ Slot vazio")


## Alterna entre modos de foco (slots, botões, filtros)
func cycle_focus_mode() -> void:
	# Remove highlights antigos
	refresh_highlight()
	remove_button_highlights()
	remove_filter_highlights()
	
	# Cicla entre modos
	if focus_mode == "slots":
		focus_mode = "buttons"
		selected_button_index = 0
		highlight_current_button()
		print("[INVENTORY UI] 🎯 Foco: BOTÕES")
	elif focus_mode == "buttons":
		focus_mode = "filters"
		selected_filter_index = 0
		highlight_current_filter()
		print("[INVENTORY UI] 🎯 Foco: FILTROS")
	else:  # filters
		focus_mode = "slots"
		selected_slot_index = 0
		refresh_highlight()
		print("[INVENTORY UI] 🎯 Foco: SLOTS")


## Navega entre botões
func navigate_buttons(direction: int) -> void:
	var buttons = [use_button, split_button, drop_button]
	var enabled_buttons = []
	
	# Filtra apenas botões habilitados
	for btn in buttons:
		if btn and not btn.disabled:
			enabled_buttons.append(btn)
	
	if enabled_buttons.is_empty():
		return
	
	remove_button_highlights()
	selected_button_index = (selected_button_index + direction) % enabled_buttons.size()
	if selected_button_index < 0:
		selected_button_index = enabled_buttons.size() + selected_button_index
	
	highlight_current_button()


## Ativa o botão atual
func activate_current_button() -> void:
	var buttons = [use_button, split_button, drop_button]
	var enabled_buttons = []
	
	for btn in buttons:
		if btn and not btn.disabled:
			enabled_buttons.append(btn)
	
	if selected_button_index >= 0 and selected_button_index < enabled_buttons.size():
		enabled_buttons[selected_button_index].emit_signal("pressed")
		print("[INVENTORY UI] ✅ Botão ativado: %s" % enabled_buttons[selected_button_index].text)


## Destaca o botão atual
func highlight_current_button() -> void:
	var buttons = [use_button, split_button, drop_button]
	var enabled_buttons = []
	
	for btn in buttons:
		if btn and not btn.disabled:
			enabled_buttons.append(btn)
	
	if selected_button_index >= 0 and selected_button_index < enabled_buttons.size():
		enabled_buttons[selected_button_index].modulate = Color(1.5, 1.5, 0.5)


## Remove highlight dos botões
func remove_button_highlights() -> void:
	var buttons = [use_button, split_button, drop_button]
	for btn in buttons:
		if btn:
			btn.modulate = Color.WHITE


## Navega entre filtros
func navigate_filters(direction: int) -> void:
	var filter_list = filter_buttons.values()
	
	if filter_list.is_empty():
		return
	
	remove_filter_highlights()
	selected_filter_index = (selected_filter_index + direction) % filter_list.size()
	if selected_filter_index < 0:
		selected_filter_index = filter_list.size() + selected_filter_index
	
	highlight_current_filter()


## Ativa o filtro atual
func activate_current_filter() -> void:
	var filter_list = filter_buttons.keys()
	
	if selected_filter_index >= 0 and selected_filter_index < filter_list.size():
		var filter_type = filter_list[selected_filter_index]
		_on_filter_changed(filter_type)
		print("[INVENTORY UI] ✅ Filtro ativado: %s" % filter_type)


## Destaca o filtro atual
func highlight_current_filter() -> void:
	var filter_list = filter_buttons.values()
	
	if selected_filter_index >= 0 and selected_filter_index < filter_list.size():
		filter_list[selected_filter_index].modulate = Color(1.5, 1.5, 0.5)


## Remove highlight dos filtros
func remove_filter_highlights() -> void:
	for btn in filter_buttons.values():
		if btn:
			btn.modulate = Color.WHITE


## Atualiza o highlight do slot selecionado
func refresh_highlight() -> void:
	# Remove highlight de todos os slots
	for i in range(slot_uis.size()):
		slot_uis[i].set_highlighted(false)
	
	# Aplica highlight no slot selecionado
	if selected_slot_index >= 0 and selected_slot_index < slot_uis.size():
		slot_uis[selected_slot_index].set_highlighted(true)


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
	# Ajusta selected_slot_index para não apontar para slot vazio
	if selected_slot_index >= non_empty_slots.size():
		selected_slot_index = max(0, non_empty_slots.size() - 1)
	refresh_highlight()
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
	all_button.pressed.connect(_on_filter_changed.bind(-1))
	filters_hbox.add_child(all_button)
	filter_buttons[-1] = all_button
	
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
		btn.pressed.connect(_on_filter_changed.bind(filter_data[1]))
		filters_hbox.add_child(btn)
		filter_buttons[filter_data[1]] = btn
	
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
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.mouse_filter = Control.MOUSE_FILTER_PASS  # Passa eventos para os filhos
	slots_vbox.add_child(scroll)
	
	grid_container = GridContainer.new()
	grid_container.columns = grid_columns
	grid_container.add_theme_constant_override("h_separation", slot_spacing)
	grid_container.add_theme_constant_override("v_separation", slot_spacing)
	grid_container.mouse_filter = Control.MOUSE_FILTER_PASS  # Passa eventos para os filhos
	scroll.add_child(grid_container)
	
	# Botões de ação
	var actions_hbox = HBoxContainer.new()
	actions_hbox.add_theme_constant_override("separation", 4)
	actions_hbox.mouse_filter = Control.MOUSE_FILTER_PASS
	slots_vbox.add_child(actions_hbox)
	
	use_button = Button.new()
	use_button.text = "Usar"
	use_button.disabled = true
	use_button.pressed.connect(_on_use_button_pressed)
	actions_hbox.add_child(use_button)
	
	split_button = Button.new()
	split_button.text = "Dividir"
	split_button.disabled = true
	split_button.pressed.connect(_on_split_button_pressed)
	actions_hbox.add_child(split_button)
	
	drop_button = Button.new()
	drop_button.text = "Dropar"
	drop_button.disabled = true
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
	if current_filter != -1:
		apply_filter()
	print("[INVENTORY UI] ✅ Inventário aberto")


## Fecha o inventário
func close_inventory() -> void:
	print("[INVENTORY UI] 📁 Fechando inventário...")
	is_open = false
	hide()
	selected_slot_index = -1
	update_action_buttons()
	print("[INVENTORY UI] ✅ Inventário fechado")


## Toggle do inventário
func toggle_inventory() -> void:
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
	
	# Double click em consumível = Usar
	# (Godot não tem double click built-in, então usamos click único)
	
	# Click esquerdo = Seleciona slot ou usa/equipa
	if mouse_button == MOUSE_BUTTON_LEFT:
		print("[INVENTORY UI] 👆 Click esquerdo")
		# Se já está selecionado, tenta usar/equipar
		if selected_slot_index == slot_index and not slot.is_empty():
			print("[INVENTORY UI] 🔄 Slot já selecionado - tentando usar/equipar")
			if slot.item_data.is_usable():
				print("[INVENTORY UI] ✅ Item é usável!")
				inventory.use_item(slot_index)
				selected_slot_index = -1
			elif slot.item_data.is_equippable:
				print("[INVENTORY UI] ✅ Item é equipável!")
				inventory.equip_item(slot_index)
				selected_slot_index = -1
		else:
			# Seleciona o slot
			print("[INVENTORY UI] ✅ Selecionando slot %d" % slot_index)
			selected_slot_index = slot_index
		
		update_action_buttons()
		highlight_selected_slot()


## Callback quando slot recebe double-click
func _on_slot_double_clicked(slot_index: int) -> void:
	print("\n[INVENTORY UI] ⚡ DOUBLE-CLICK detectado no slot %d" % slot_index)
	
	if not inventory:
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


## Destaca visualmente o slot selecionado
func highlight_selected_slot() -> void:
	for i in range(slot_uis.size()):
		var slot_ui = slot_uis[i]
		if i == selected_slot_index:
			slot_ui.modulate = Color(1.2, 1.2, 1.0)  # Amarelo claro
		else:
			slot_ui.modulate = Color.WHITE


## Callback quando slot de equipamento é clicado
func _on_equipment_slot_clicked(_slot_index: int, mouse_button: int, equip_type: ItemData.EquipmentSlot) -> void:
	if not inventory:
		return
	
	if mouse_button == MOUSE_BUTTON_LEFT:
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
	
	if selected_slot_index == -1:
		print("[INVENTORY UI] ❌ Nenhum slot selecionado")
		return
	
	if not inventory:
		print("[INVENTORY UI] ❌ Inventário é NULL!")
		return
	
	print("[INVENTORY UI]    Slot selecionado: %d" % selected_slot_index)
	
	if inventory.use_item(selected_slot_index):
		print("[INVENTORY UI] ✅ Item usado com sucesso")
		selected_slot_index = -1
		update_action_buttons()
	else:
		print("[INVENTORY UI] ❌ Falha ao usar item")


## Callback para botão "Dividir"
func _on_split_button_pressed() -> void:
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
	
	selected_slot_index = -1
	update_action_buttons()


## Callback para botão "Dropar"
func _on_drop_button_pressed() -> void:
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
	selected_slot_index = -1
	update_action_buttons()


## Atualiza estado dos botões de ação
func update_action_buttons() -> void:
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
