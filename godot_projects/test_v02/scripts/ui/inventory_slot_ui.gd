extends Panel
class_name InventorySlotUI

## UI para um slot individual do inventário com drag and drop

signal slot_clicked(slot_index: int, mouse_button: int)
signal slot_right_clicked(slot_index: int)
signal drag_started(slot_index: int)
signal drag_ended(slot_index: int)

@export var slot_index: int = 0
@export var slot_size: Vector2 = Vector2(64, 64)

var inventory_slot: InventorySlot
var is_dragging: bool = false

@onready var icon_rect: TextureRect = $IconRect
@onready var quantity_label: Label = $QuantityLabel
@onready var durability_bar: ProgressBar = $DurabilityBar if has_node("DurabilityBar") else null


func _ready() -> void:
	custom_minimum_size = slot_size
	
	# Configura tooltip
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Cria nós se não existirem
	if not has_node("IconRect"):
		icon_rect = TextureRect.new()
		icon_rect.name = "IconRect"
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(icon_rect)
	
	if not has_node("QuantityLabel"):
		quantity_label = Label.new()
		quantity_label.name = "QuantityLabel"
		quantity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		quantity_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		quantity_label.add_theme_font_size_override("font_size", 14)
		quantity_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(quantity_label)
	
	update_visuals()


## Atualiza a aparência do slot
func update_visuals() -> void:
	if inventory_slot == null or inventory_slot.is_empty():
		icon_rect.texture = null
		quantity_label.text = ""
		tooltip_text = ""
		modulate = Color(1, 1, 1, 0.5)
		return
	
	modulate = Color.WHITE
	var item = inventory_slot.item_data
	
	# Ícone
	icon_rect.texture = item.icon
	
	# Quantidade
	if item.is_stackable and inventory_slot.quantity > 1:
		quantity_label.text = str(inventory_slot.quantity)
	else:
		quantity_label.text = ""
	
	# Tooltip
	tooltip_text = item.get_tooltip_text() if item else ""


## Define o slot de inventário que este UI representa
func set_inventory_slot(slot: InventorySlot) -> void:
	# Desconecta do slot anterior
	if inventory_slot and inventory_slot.slot_changed.is_connected(_on_slot_changed):
		inventory_slot.slot_changed.disconnect(_on_slot_changed)
	
	inventory_slot = slot
	
	# Conecta ao novo slot
	if inventory_slot:
		inventory_slot.slot_changed.connect(_on_slot_changed)
	
	update_visuals()


## Callback quando o slot de dados muda
func _on_slot_changed() -> void:
	update_visuals()


## Input handling
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				slot_clicked.emit(slot_index, MOUSE_BUTTON_LEFT)
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				slot_right_clicked.emit(slot_index)
				slot_clicked.emit(slot_index, MOUSE_BUTTON_RIGHT)


## Drag and drop
func _get_drag_data(_at_position: Vector2) -> Variant:
	if inventory_slot == null or inventory_slot.is_empty():
		return null
	
	is_dragging = true
	drag_started.emit(slot_index)
	
	# Cria preview visual
	var preview = TextureRect.new()
	preview.texture = inventory_slot.item_data.icon
	preview.custom_minimum_size = slot_size * 0.8
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.modulate = Color(1, 1, 1, 0.8)
	
	set_drag_preview(preview)
	
	return {
		"slot_index": slot_index,
		"item": inventory_slot.item_data,
		"quantity": inventory_slot.quantity
	}


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if typeof(data) != TYPE_DICTIONARY:
		return false
	
	if not data.has("slot_index"):
		return false
	
	return true


func _drop_data(at_position: Vector2, data: Variant) -> void:
	if not _can_drop_data(at_position, data):
		return
	
	drag_ended.emit(data.slot_index)
	
	# Emite evento de que houve drop (a UI principal vai lidar com a lógica)
	slot_clicked.emit(slot_index, MOUSE_BUTTON_LEFT)


## Visual feedback quando hovering
func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_ENTER:
		if not inventory_slot or not inventory_slot.is_empty():
			modulate = Color(1.2, 1.2, 1.2)
	elif what == NOTIFICATION_MOUSE_EXIT:
		update_visuals()
