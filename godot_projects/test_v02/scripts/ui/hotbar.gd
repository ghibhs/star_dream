extends CanvasLayer
class_name Hotbar

## Hotbar para acesso rápido a itens (slots 1-9)

@export var inventory: Inventory
@export var hotbar_size: int = 9
@export var slot_size: Vector2 = Vector2(56, 56)
@export var slot_spacing: int = 4

var slot_uis: Array = []
var hotbar_container: HBoxContainer

signal hotbar_slot_used(slot_index: int)


func _ready() -> void:
	create_hotbar_ui()


## Cria a UI da hotbar
func create_hotbar_ui() -> void:
	# Container principal (centralizado embaixo)
	var margin = MarginContainer.new()
	margin.anchor_left = 0.5
	margin.anchor_top = 1.0
	margin.anchor_right = 0.5
	margin.anchor_bottom = 1.0
	margin.offset_left = -((slot_size.x + slot_spacing) * hotbar_size) / 2.0
	margin.offset_top = -slot_size.y - 20  # 20px de margem do fundo
	margin.offset_right = ((slot_size.x + slot_spacing) * hotbar_size) / 2.0
	margin.offset_bottom = -20
	add_child(margin)
	
	# Background panel
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2((slot_size.x + slot_spacing) * hotbar_size + 16, slot_size.y + 16)
	margin.add_child(panel)
	
	# Container horizontal para os slots
	hotbar_container = HBoxContainer.new()
	hotbar_container.add_theme_constant_override("separation", slot_spacing)
	hotbar_container.position = Vector2(8, 8)
	panel.add_child(hotbar_container)
	
	# Cria os 9 slots
	for i in range(hotbar_size):
		var slot_ui = create_hotbar_slot(i)
		hotbar_container.add_child(slot_ui)
		slot_uis.append(slot_ui)


## Cria um slot individual da hotbar
func create_hotbar_slot(index: int) -> Control:
	var slot = Panel.new()
	slot.custom_minimum_size = slot_size
	slot.tooltip_text = "Slot %d (pressione %d)" % [index + 1, index + 1]
	
	# Ícone do item
	var icon = TextureRect.new()
	icon.name = "Icon"
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.anchor_right = 1.0
	icon.anchor_bottom = 1.0
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(icon)
	
	# Label de quantidade
	var quantity = Label.new()
	quantity.name = "Quantity"
	quantity.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	quantity.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	quantity.anchor_left = 0.0
	quantity.anchor_top = 0.0
	quantity.anchor_right = 1.0
	quantity.anchor_bottom = 1.0
	quantity.add_theme_font_size_override("font_size", 12)
	quantity.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(quantity)
	
	# Label do número do slot (canto superior esquerdo)
	var number = Label.new()
	number.name = "Number"
	number.text = str(index + 1)
	number.add_theme_font_size_override("font_size", 10)
	number.add_theme_color_override("font_color", Color(1, 1, 1, 0.5))
	number.position = Vector2(2, 2)
	number.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(number)
	
	return slot


## Atualiza display da hotbar
func update_hotbar() -> void:
	if not inventory:
		return
	
	for i in range(min(hotbar_size, slot_uis.size())):
		if i >= inventory.slots.size():
			break
		
		var slot = inventory.slots[i]
		var slot_ui = slot_uis[i]
		
		var icon = slot_ui.get_node("Icon") as TextureRect
		var quantity_label = slot_ui.get_node("Quantity") as Label
		
		if slot.is_empty():
			icon.texture = null
			quantity_label.text = ""
			slot_ui.modulate = Color(1, 1, 1, 0.5)
		else:
			icon.texture = slot.item_data.icon
			if slot.item_data.is_stackable and slot.quantity > 1:
				quantity_label.text = str(slot.quantity)
			else:
				quantity_label.text = ""
			slot_ui.modulate = Color.WHITE


## Input para usar slots da hotbar (1-9)
func _input(event: InputEvent) -> void:
	# Teclas 1-9
	if event is InputEventKey and event.pressed and not event.echo:
		var key = event.keycode
		
		# KEY_1 = 49, KEY_9 = 57
		if key >= KEY_1 and key <= KEY_9:
			var slot_index = key - KEY_1  # 0-8
			use_hotbar_slot(slot_index)
			get_viewport().set_input_as_handled()


## Usa um item da hotbar
func use_hotbar_slot(slot_index: int) -> void:
	if not inventory or slot_index < 0 or slot_index >= hotbar_size:
		return
	
	if slot_index >= inventory.slots.size():
		return
	
	var slot = inventory.slots[slot_index]
	
	if slot.is_empty():
		print("[HOTBAR] Slot %d vazio" % (slot_index + 1))
		return
	
	var item = slot.item_data
	
	print("[HOTBAR] Usando item: %s" % item.item_name)
	
	# Equipar se for equipável
	if item.is_equippable:
		inventory.equip_item(slot_index)
		update_hotbar()
		return
	
	# Consumir se for consumível
	if item.item_type == ItemData.ItemType.CONSUMABLE:
		# TODO: Aplicar efeitos do consumível
		print("[HOTBAR] 🍺 Consumindo: %s" % item.item_name)
		inventory.remove_item(item, 1)
		update_hotbar()
		hotbar_slot_used.emit(slot_index)
		return
	
	print("[HOTBAR] ⚠️ Item não pode ser usado: %s" % item.item_name)


## Configura o inventário
func setup_inventory(inv: Inventory) -> void:
	inventory = inv
	
	if not inventory.inventory_changed.is_connected(update_hotbar):
		inventory.inventory_changed.connect(update_hotbar)
	
	update_hotbar()
