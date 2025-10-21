extends Node
class_name Inventory

## Sistema de inventário com slots para itens e equipamentos

signal inventory_changed()
signal item_added(item: ItemData, quantity: int)
signal item_removed(item: ItemData, quantity: int)
signal equipment_changed(slot_type: ItemData.EquipmentSlot)

@export var inventory_size: int = 30
@export var enable_equipment_slots: bool = true

## Slots principais do inventário
var slots: Array[InventorySlot] = []

## Slots de equipamento (separados)
var equipment_slots: Dictionary = {
	ItemData.EquipmentSlot.HEAD: null,
	ItemData.EquipmentSlot.CHEST: null,
	ItemData.EquipmentSlot.LEGS: null,
	ItemData.EquipmentSlot.BOOTS: null,
	ItemData.EquipmentSlot.GLOVES: null,
	ItemData.EquipmentSlot.RING: null,
	ItemData.EquipmentSlot.AMULET: null,
	ItemData.EquipmentSlot.WEAPON_PRIMARY: null,
	ItemData.EquipmentSlot.WEAPON_SECONDARY: null,
}


func _ready() -> void:
	initialize_inventory()


## Inicializa os slots do inventário
func initialize_inventory() -> void:
	slots.clear()
	for i in range(inventory_size):
		var slot = InventorySlot.new()
		slot.slot_changed.connect(_on_slot_changed)
		slots.append(slot)
	
	print("[INVENTORY] Inventário inicializado com %d slots" % inventory_size)


## Adiciona um item ao inventário
func add_item(item: ItemData, quantity: int = 1) -> bool:
	if item == null or quantity <= 0:
		return false
	
	print("[INVENTORY] Tentando adicionar: %s x%d" % [item.item_name, quantity])
	
	var remaining = quantity
	
	# Primeiro, tenta empilhar em slots existentes
	if item.is_stackable:
		for slot in slots:
			if slot.is_empty():
				continue
			
			if slot.can_stack_with(item):
				var leftover = slot.add(remaining)
				remaining = leftover
				
				if remaining <= 0:
					print("[INVENTORY] ✅ Item empilhado com sucesso!")
					item_added.emit(item, quantity)
					inventory_changed.emit()
					return true
	
	# Se ainda sobrou, cria novos slots
	while remaining > 0:
		var empty_slot = find_empty_slot()
		if empty_slot == null:
			print("[INVENTORY] ⚠️ Inventário cheio! Não coube: %d itens" % remaining)
			if remaining < quantity:
				item_added.emit(item, quantity - remaining)
				inventory_changed.emit()
			return false
		
		var amount_to_add = min(remaining, item.max_stack_size if item.is_stackable else 1)
		empty_slot.set_item(item, amount_to_add)
		remaining -= amount_to_add
	
	print("[INVENTORY] ✅ Item adicionado com sucesso!")
	item_added.emit(item, quantity)
	inventory_changed.emit()
	return true


## Remove um item do inventário
func remove_item(item: ItemData, quantity: int = 1) -> int:
	if item == null or quantity <= 0:
		return 0
	
	var removed_total = 0
	
	for slot in slots:
		if slot.is_empty() or slot.item_data != item:
			continue
		
		var to_remove = min(quantity - removed_total, slot.quantity)
		slot.remove(to_remove)
		removed_total += to_remove
		
		if removed_total >= quantity:
			break
	
	if removed_total > 0:
		print("[INVENTORY] Removido: %s x%d" % [item.item_name, removed_total])
		item_removed.emit(item, removed_total)
		inventory_changed.emit()
	
	return removed_total


## Conta quantos itens de um tipo existem no inventário
func count_item(item: ItemData) -> int:
	var total = 0
	for slot in slots:
		if not slot.is_empty() and slot.item_data == item:
			total += slot.quantity
	return total


## Verifica se tem espaço no inventário
func has_space_for(item: ItemData, quantity: int = 1) -> bool:
	if item.is_stackable:
		# Verifica slots existentes com espaço
		var space = 0
		for slot in slots:
			if slot.is_empty():
				space += item.max_stack_size
			elif slot.item_data == item and slot.can_add_more():
				space += (item.max_stack_size - slot.quantity)
			
			if space >= quantity:
				return true
		return false
	else:
		# Item não empilhável precisa de slots vazios
		return get_empty_slot_count() >= quantity


## Encontra um slot vazio
func find_empty_slot() -> InventorySlot:
	for slot in slots:
		if slot.is_empty():
			return slot
	return null


## Conta slots vazios
func get_empty_slot_count() -> int:
	var count = 0
	for slot in slots:
		if slot.is_empty():
			count += 1
	return count


## Troca itens entre dois slots
func swap_slots(index_a: int, index_b: int) -> void:
	if index_a < 0 or index_a >= slots.size() or index_b < 0 or index_b >= slots.size():
		return
	
	var temp_item = slots[index_a].item_data
	var temp_quantity = slots[index_a].quantity
	
	slots[index_a].set_item(slots[index_b].item_data, slots[index_b].quantity)
	slots[index_b].set_item(temp_item, temp_quantity)
	
	inventory_changed.emit()


## Move item de um slot para outro (com stack se possível)
func move_item(from_index: int, to_index: int) -> void:
	if from_index < 0 or from_index >= slots.size() or to_index < 0 or to_index >= slots.size():
		return
	
	var from_slot = slots[from_index]
	var to_slot = slots[to_index]
	
	if from_slot.is_empty():
		return
	
	# Se destino está vazio, move tudo
	if to_slot.is_empty():
		to_slot.set_item(from_slot.item_data, from_slot.quantity)
		from_slot.clear()
		inventory_changed.emit()
		return
	
	# Se pode empilhar, tenta
	if to_slot.can_stack_with(from_slot.item_data):
		var leftover = to_slot.add(from_slot.quantity)
		if leftover > 0:
			from_slot.quantity = leftover
			from_slot.slot_changed.emit()
		else:
			from_slot.clear()
		inventory_changed.emit()
		return
	
	# Se não pode empilhar, troca
	swap_slots(from_index, to_index)


## Divide um slot (split)
func split_slot(index: int) -> int:
	if index < 0 or index >= slots.size():
		return -1
	
	var slot = slots[index]
	if slot.quantity <= 1:
		return -1
	
	var split_data = slot.split()
	if split_data.item == null:
		return -1
	
	# Procura slot vazio para colocar a metade
	var empty_slot = find_empty_slot()
	if empty_slot:
		empty_slot.set_item(split_data.item, split_data.quantity)
		inventory_changed.emit()
		return slots.find(empty_slot)
	
	return -1


## Equipa um item
func equip_item(inventory_index: int) -> bool:
	if inventory_index < 0 or inventory_index >= slots.size():
		return false
	
	var slot = slots[inventory_index]
	if slot.is_empty() or not slot.item_data.is_equippable:
		return false
	
	var item = slot.item_data
	var equip_slot_type = item.equipment_slot
	
	# Desequipa o que está no slot de equipamento (se houver)
	if equipment_slots[equip_slot_type] != null:
		unequip_item(equip_slot_type)
	
	# Equipa o novo item
	equipment_slots[equip_slot_type] = item
	slot.remove(1)  # Remove 1 do inventário
	
	print("[INVENTORY] ⚔️ Equipado: %s no slot %s" % [item.item_name, ItemData.EquipmentSlot.keys()[equip_slot_type]])
	equipment_changed.emit(equip_slot_type)
	inventory_changed.emit()
	return true


## Desequipa um item
func unequip_item(equip_slot_type: ItemData.EquipmentSlot) -> bool:
	var item = equipment_slots[equip_slot_type]
	if item == null:
		return false
	
	# Tenta adicionar de volta ao inventário
	if not add_item(item, 1):
		print("[INVENTORY] ⚠️ Sem espaço para desequipar!")
		return false
	
	equipment_slots[equip_slot_type] = null
	
	print("[INVENTORY] 🎒 Desequipado: %s" % item.item_name)
	equipment_changed.emit(equip_slot_type)
	return true


## Retorna o item equipado em um slot
func get_equipped_item(equip_slot_type: ItemData.EquipmentSlot) -> ItemData:
	return equipment_slots.get(equip_slot_type, null)


## Transfere itens para outro inventário
func transfer_to(target_inventory: Inventory, from_index: int, quantity: int = -1) -> bool:
	if from_index < 0 or from_index >= slots.size():
		return false
	
	var slot = slots[from_index]
	if slot.is_empty():
		return false
	
	var amount = quantity if quantity > 0 else slot.quantity
	amount = min(amount, slot.quantity)
	
	if target_inventory.add_item(slot.item_data, amount):
		slot.remove(amount)
		print("[INVENTORY] ↔️ Transferido: %s x%d" % [slot.item_data.item_name, amount])
		return true
	
	return false


## Callback quando um slot muda
func _on_slot_changed() -> void:
	inventory_changed.emit()


## Debug: imprime todo o inventário
func print_inventory() -> void:
	print("\n[INVENTORY] ═══════════════════════════════")
	print("[INVENTORY] Slots ocupados: %d/%d" % [inventory_size - get_empty_slot_count(), inventory_size])
	for i in range(slots.size()):
		if not slots[i].is_empty():
			print("[INVENTORY] Slot %d: %s" % [i, slots[i].get_debug_string()])
	print("[INVENTORY] ═══════════════════════════════\n")
