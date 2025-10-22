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

var icon_rect: TextureRect
var quantity_label: Label
var durability_bar: ProgressBar


func _ready() -> void:
	custom_minimum_size = slot_size
	
	# Configura tooltip e input
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	print("[SLOT UI] 🎯 Slot %d inicializado" % slot_index)
	print("[SLOT UI]    Mouse filter: STOP")
	print("[SLOT UI]    Size: ", slot_size)
	
	# Cria nós se não existirem
	if has_node("IconRect"):
		icon_rect = $IconRect
	else:
		icon_rect = TextureRect.new()
		icon_rect.name = "IconRect"
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(icon_rect)
	
	# Garante que o ícone preencha todo o slot mas ignora mouse
	icon_rect.anchor_right = 1.0
	icon_rect.anchor_bottom = 1.0
	icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if has_node("QuantityLabel"):
		quantity_label = $QuantityLabel
	else:
		quantity_label = Label.new()
		quantity_label.name = "QuantityLabel"
		quantity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		quantity_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		quantity_label.add_theme_font_size_override("font_size", 14)
		quantity_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(quantity_label)
	
	# Posiciona o label no canto inferior direito
	quantity_label.anchor_left = 0.0
	quantity_label.anchor_top = 0.0
	quantity_label.anchor_right = 1.0
	quantity_label.anchor_bottom = 1.0
	quantity_label.offset_right = -4
	quantity_label.offset_bottom = -2
	quantity_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if has_node("DurabilityBar"):
		durability_bar = $DurabilityBar
	
	print("[SLOT UI] ✅ Slot %d pronto para receber input" % slot_index)
	
	# Só atualiza visuais se tiver um slot configurado
	if inventory_slot:
		update_visuals()


## Atualiza a aparência do slot
func update_visuals() -> void:
	# Verifica se os nós existem
	if not icon_rect or not quantity_label:
		print("[SLOT UI] ⚠️ Slot %d: icon_rect ou quantity_label NULL!" % slot_index)
		return
	
	if inventory_slot == null or inventory_slot.is_empty():
		icon_rect.texture = null
		quantity_label.text = ""
		tooltip_text = ""
		modulate = Color(1, 1, 1, 0.5)
		return
	
	modulate = Color.WHITE
	var item = inventory_slot.item_data
	
	# Ícone
	icon_rect.texture = item.icon if item else null
	print("[SLOT UI] 🎨 Slot %d: Aplicando textura %s" % [slot_index, "SIM" if item.icon else "NULL"])
	
	# Quantidade
	if item and item.is_stackable and inventory_slot.quantity > 1:
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
	print("[SLOT UI] 🔄 Slot %d mudou! Atualizando visual..." % slot_index)
	if inventory_slot and not inventory_slot.is_empty():
		print("[SLOT UI]    Item: %s x%d" % [inventory_slot.item_data.item_name, inventory_slot.quantity])
	update_visuals()


## Input handling
func _gui_input(event: InputEvent) -> void:
	# Apenas processa clicks, não hover (removido logs de motion)
	if event is InputEventMouseButton:
		print("[SLOT UI] 🖱️ Mouse BUTTON event no slot %d" % slot_index)
		print("[SLOT UI]    Botão: ", event.button_index)
		print("[SLOT UI]    Pressionado: ", event.pressed)
		
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				print("[SLOT UI] ✅ CLIQUE ESQUERDO no slot %d" % slot_index)
				slot_clicked.emit(slot_index, MOUSE_BUTTON_LEFT)
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				print("[SLOT UI] ✅ CLIQUE DIREITO no slot %d" % slot_index)
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
