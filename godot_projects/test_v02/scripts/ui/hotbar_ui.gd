extends HBoxContainer
class_name HotbarUI

## Barra de acesso rápido (Hotbar) para itens favoritos

signal hotbar_slot_used(slot_index: int)

@export var inventory: Inventory
@export var hotbar_size: int = 5  # Número de slots na hotbar
@export var slot_size: Vector2 = Vector2(64, 64)

var hotbar_slots: Array[InventorySlotUI] = []
var hotbar_item_indices: Array[int] = []  # Índices dos itens no inventário principal


func _ready() -> void:
	print("\n[HOTBAR] 🎮 Inicializando hotbar...")
	print("[HOTBAR]    Tamanho: %d slots" % hotbar_size)
	
	create_hotbar()
	
	if inventory:
		setup_inventory(inventory)
	else:
		print("[HOTBAR] ⚠️ Inventário não configurado no _ready")


## Cria os slots visuais da hotbar
func create_hotbar() -> void:
	# Limpa slots existentes
	for child in get_children():
		child.queue_free()
	
	hotbar_slots.clear()
	hotbar_item_indices.clear()
	
	# Cria novos slots
	for i in range(hotbar_size):
		var slot_ui = InventorySlotUI.new()
		slot_ui.slot_index = i
		slot_ui.slot_size = slot_size
		slot_ui.custom_minimum_size = slot_size
		
		# Adiciona label de número (1-5)
		var number_label = Label.new()
		number_label.text = str(i + 1)
		number_label.add_theme_font_size_override("font_size", 16)
		number_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.7))
		number_label.position = Vector2(4, 4)
		slot_ui.add_child(number_label)
		
		slot_ui.slot_clicked.connect(_on_hotbar_slot_clicked)
		add_child(slot_ui)
		hotbar_slots.append(slot_ui)
		hotbar_item_indices.append(-1)  # -1 = slot vazio


## Configura referência ao inventário
func setup_inventory(inv: Inventory) -> void:
	print("\n[HOTBAR] 🔗 Conectando ao inventário...")
	inventory = inv
	
	if not inventory:
		print("[HOTBAR] ❌ Inventário é NULL!")
		return
	
	if not inventory.inventory_changed.is_connected(_on_inventory_changed):
		inventory.inventory_changed.connect(_on_inventory_changed)
		print("[HOTBAR] ✅ Sinal inventory_changed conectado")
	
	update_hotbar()
	print("[HOTBAR] ✅ Hotbar configurada")


## Adiciona um item do inventário à hotbar
func add_to_hotbar(inventory_index: int, hotbar_index: int) -> void:
	if hotbar_index < 0 or hotbar_index >= hotbar_size:
		return
	
	if inventory_index < 0 or inventory_index >= inventory.slots.size():
		return
	
	# Remove item anterior se houver
	if hotbar_item_indices[hotbar_index] != -1:
		hotbar_item_indices[hotbar_index] = -1
	
	# Adiciona novo item
	hotbar_item_indices[hotbar_index] = inventory_index
	update_hotbar_slot(hotbar_index)
	
	print("[HOTBAR] Item adicionado ao slot %d: índice %d" % [hotbar_index, inventory_index])


## Remove item da hotbar
func remove_from_hotbar(hotbar_index: int) -> void:
	if hotbar_index < 0 or hotbar_index >= hotbar_size:
		return
	
	hotbar_item_indices[hotbar_index] = -1
	update_hotbar_slot(hotbar_index)


## Atualiza visualmente um slot da hotbar
func update_hotbar_slot(hotbar_index: int) -> void:
	if hotbar_index < 0 or hotbar_index >= hotbar_size:
		return
	
	var slot_ui = hotbar_slots[hotbar_index]
	var inventory_index = hotbar_item_indices[hotbar_index]
	
	if inventory_index == -1 or not inventory:
		slot_ui.set_inventory_slot(null)
		return
	
	if inventory_index >= inventory.slots.size():
		return
	
	var inventory_slot = inventory.slots[inventory_index]
	slot_ui.set_inventory_slot(inventory_slot)


## Atualiza toda a hotbar
func update_hotbar() -> void:
	for i in range(hotbar_size):
		update_hotbar_slot(i)


## Usa o item de um slot da hotbar
func use_hotbar_slot(hotbar_index: int) -> void:
	print("\n[HOTBAR] 🎯 Tentando usar slot %d da hotbar" % hotbar_index)
	
	if hotbar_index < 0 or hotbar_index >= hotbar_size:
		print("[HOTBAR] ❌ Índice inválido: %d (máx: %d)" % [hotbar_index, hotbar_size - 1])
		return
	
	var inventory_index = hotbar_item_indices[hotbar_index]
	print("[HOTBAR]    Índice do inventário: %d" % inventory_index)
	
	if inventory_index == -1:
		print("[HOTBAR] ⚠️ Slot da hotbar está vazio")
		return
	
	if not inventory:
		print("[HOTBAR] ❌ Inventário é NULL!")
		return
	
	# Verifica se o índice ainda é válido
	if inventory_index >= inventory.slots.size():
		print("[HOTBAR] ❌ Índice inválido no inventário: %d >= %d" % [inventory_index, inventory.slots.size()])
		return
	
	var slot = inventory.slots[inventory_index]
	if slot.is_empty():
		print("[HOTBAR] ⚠️ Item do inventário foi removido")
		hotbar_item_indices[hotbar_index] = -1
		update_hotbar_slot(hotbar_index)
		return
	
	print("[HOTBAR]    Item: %s" % slot.item_data.item_name)
	
	# Usa o item do inventário
	if inventory.use_item(inventory_index):
		print("[HOTBAR] ✅ Item usado do slot %d" % hotbar_index)
		hotbar_slot_used.emit(hotbar_index)
	else:
		print("[HOTBAR] ❌ Falha ao usar item")


## Input para teclas 1-5
func _input(event: InputEvent) -> void:
	if not visible:
		return
	
	# Teclas numéricas 1-5
	for i in range(min(5, hotbar_size)):
		var key = KEY_1 + i
		if event is InputEventKey and event.pressed and event.keycode == key:
			print("[HOTBAR] ⌨️ Tecla %d pressionada" % (i + 1))
			use_hotbar_slot(i)
			get_viewport().set_input_as_handled()


## Callback quando o inventário muda
func _on_inventory_changed() -> void:
	update_hotbar()


## Callback quando um slot da hotbar é clicado
func _on_hotbar_slot_clicked(slot_index: int, mouse_button: int) -> void:
	if mouse_button == MOUSE_BUTTON_LEFT:
		use_hotbar_slot(slot_index)
	elif mouse_button == MOUSE_BUTTON_RIGHT:
		# Botão direito remove da hotbar
		remove_from_hotbar(slot_index)


## Salva a configuração da hotbar
func save_to_dict() -> Dictionary:
	return {
		"hotbar_items": hotbar_item_indices.duplicate()
	}


## Carrega a configuração da hotbar
func load_from_dict(save_data: Dictionary) -> void:
	if save_data.has("hotbar_items"):
		hotbar_item_indices = save_data.hotbar_items.duplicate()
		update_hotbar()
		print("[HOTBAR] ✅ Configuração carregada")
