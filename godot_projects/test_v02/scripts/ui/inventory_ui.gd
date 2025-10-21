extends CanvasLayer
class_name InventoryUI

## UI principal do inventário com drag and drop, split, e equipamentos

@export var inventory: Inventory
@export var grid_columns: int = 6
@export var slot_size: Vector2 = Vector2(64, 64)
@export var slot_spacing: int = 4

var slot_uis: Array[InventorySlotUI] = []
var is_open: bool = false

# Drag state
var dragging_from_slot: int = -1

# Nós da UI
var panel: Panel
var grid_container: GridContainer
var equipment_panel: Panel
var close_button: Button
var split_button: Button

# Equipment slot UIs
var equipment_slot_uis: Dictionary = {}


func _ready() -> void:
	# Esconde por padrão
	hide()
	
	create_ui()
	
	if inventory:
		setup_inventory(inventory)


## Cria toda a estrutura da UI
func create_ui() -> void:
	# Panel principal
	panel = Panel.new()
	panel.name = "InventoryPanel"
	panel.custom_minimum_size = Vector2(450, 500)
	panel.position = Vector2(100, 100)
	add_child(panel)
	
	# VBox para organizar conteúdo
	var vbox = VBoxContainer.new()
	vbox.anchor_right = 1
	vbox.anchor_bottom = 1
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
	
	# HBox para slots principais e equipamentos
	var hbox_main = HBoxContainer.new()
	hbox_main.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(hbox_main)
	
	# === GRID DE SLOTS PRINCIPAIS ===
	var slots_vbox = VBoxContainer.new()
	slots_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_main.add_child(slots_vbox)
	
	var slots_label = Label.new()
	slots_label.text = "Itens"
	slots_label.add_theme_font_size_override("font_size", 16)
	slots_vbox.add_child(slots_label)
	
	# ScrollContainer para os slots
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	slots_vbox.add_child(scroll)
	
	grid_container = GridContainer.new()
	grid_container.columns = grid_columns
	grid_container.add_theme_constant_override("h_separation", slot_spacing)
	grid_container.add_theme_constant_override("v_separation", slot_spacing)
	scroll.add_child(grid_container)
	
	# Botões de ação
	var actions_hbox = HBoxContainer.new()
	slots_vbox.add_child(actions_hbox)
	
	split_button = Button.new()
	split_button.text = "Dividir (Shift+Click)"
	split_button.disabled = true
	actions_hbox.add_child(split_button)
	
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
	inventory = inv
	
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
		slot_ui.slot_clicked.connect(_on_slot_clicked)
		slot_ui.slot_right_clicked.connect(_on_slot_right_clicked)
		
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
	is_open = true
	show()
	print("[INVENTORY UI] Inventário aberto")


## Fecha o inventário
func close_inventory() -> void:
	is_open = false
	hide()
	print("[INVENTORY UI] Inventário fechado")


## Toggle do inventário
func toggle_inventory() -> void:
	if is_open:
		close_inventory()
	else:
		open_inventory()


## Callback quando um slot é clicado
func _on_slot_clicked(slot_index: int, mouse_button: int) -> void:
	if not inventory:
		return
	
	# Shift + Click = Split
	if Input.is_key_pressed(KEY_SHIFT) and mouse_button == MOUSE_BUTTON_LEFT:
		inventory.split_slot(slot_index)
		return
	
	# Ctrl + Click = Drop/Delete (poderia implementar)
	if Input.is_key_pressed(KEY_CTRL) and mouse_button == MOUSE_BUTTON_LEFT:
		print("[INVENTORY UI] Drop não implementado ainda")
		return
	
	# Click normal em item equipável = equipar
	var slot = inventory.slots[slot_index]
	if not slot.is_empty() and slot.item_data.is_equippable:
		if mouse_button == MOUSE_BUTTON_LEFT:
			inventory.equip_item(slot_index)


## Callback quando um slot é clicado com botão direito
func _on_slot_right_clicked(slot_index: int) -> void:
	print("[INVENTORY UI] Right click no slot %d" % slot_index)
	# Poderia abrir menu contextual aqui


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


## Input handler
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		toggle_inventory()
		get_viewport().set_input_as_handled()
