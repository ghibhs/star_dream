extends Resource
class_name InventorySlot

## Um slot do inventário contendo um item e sua quantidade

signal slot_changed()

@export var item_data: ItemData
@export var quantity: int = 0


func _init(p_item: ItemData = null, p_quantity: int = 0) -> void:
	item_data = p_item
	quantity = p_quantity


## Verifica se o slot está vazio
func is_empty() -> bool:
	return item_data == null or quantity <= 0


## Verifica se pode adicionar mais itens (respeitando stack)
func can_add_more() -> bool:
	if is_empty():
		return true
	if not item_data.is_stackable:
		return false
	return quantity < item_data.max_stack_size


## Adiciona quantidade ao slot, retorna quanto NÃO coube
func add(amount: int) -> int:
	if is_empty():
		return amount  # Não pode adicionar em slot vazio sem item definido
	
	if not item_data.is_stackable and quantity > 0:
		return amount  # Item não empilhável já está ocupando o slot
	
	var space_available = item_data.max_stack_size - quantity
	var amount_to_add = min(amount, space_available)
	
	quantity += amount_to_add
	slot_changed.emit()
	
	return amount - amount_to_add  # Retorna o que sobrou


## Remove quantidade do slot, retorna quanto foi realmente removido
func remove(amount: int) -> int:
	var amount_to_remove = min(amount, quantity)
	quantity -= amount_to_remove
	
	if quantity <= 0:
		clear()
	else:
		slot_changed.emit()
	
	return amount_to_remove


## Limpa o slot completamente
func clear() -> void:
	item_data = null
	quantity = 0
	slot_changed.emit()


## Define o item e quantidade
func set_item(p_item: ItemData, p_quantity: int = 1) -> void:
	item_data = p_item
	quantity = p_quantity
	slot_changed.emit()


## Verifica se pode fazer stack com outro item
func can_stack_with(other_item: ItemData) -> bool:
	if is_empty() or other_item == null:
		return false
	
	return (item_data == other_item and 
			item_data.is_stackable and 
			quantity < item_data.max_stack_size)


## Pega tudo do slot e limpa ele
func take_all() -> Dictionary:
	var result = {
		"item": item_data,
		"quantity": quantity
	}
	clear()
	return result


## Divide o slot ao meio (para mecânica de split)
func split() -> Dictionary:
	if quantity <= 1:
		return {"item": null, "quantity": 0}
	
	var half = int(quantity / 2.0)
	var result = {
		"item": item_data,
		"quantity": half
	}
	
	quantity -= half
	slot_changed.emit()
	
	return result


## Retorna informações do slot para debug
func get_debug_string() -> String:
	if is_empty():
		return "[Empty Slot]"
	return "[%s x%d]" % [item_data.item_name, quantity]
