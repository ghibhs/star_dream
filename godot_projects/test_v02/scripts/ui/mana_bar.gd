# ManaBar.gd
extends ProgressBar

@onready var player = get_tree().get_first_node_in_group("player")

@export var max_mana: float = 100.0
var current_mana: float = 100.0

func _ready() -> void:
	max_value = max_mana
	value = current_mana
	
	# Estilo da barra
	modulate = Color(0.2, 0.5, 1.0)  # Azul para mana
	
	if player:
		# Conectar aos sinais do player se existirem
		if player.has_signal("mana_changed"):
			player.mana_changed.connect(_on_mana_changed)
		if player.has_signal("max_mana_changed"):
			player.max_mana_changed.connect(_on_max_mana_changed)


func _on_mana_changed(new_mana: float) -> void:
	current_mana = new_mana
	value = current_mana


func _on_max_mana_changed(new_max_mana: float) -> void:
	max_mana = new_max_mana
	max_value = max_mana


## Usar mana (retorna true se tiver mana suficiente)
func use_mana(amount: float) -> bool:
	if current_mana >= amount:
		current_mana -= amount
		value = current_mana
		if player and player.has_signal("mana_changed"):
			player.emit_signal("mana_changed", current_mana)
		return true
	return false


## Regenerar mana
func regenerate_mana(amount: float) -> void:
	current_mana = min(current_mana + amount, max_mana)
	value = current_mana
	if player and player.has_signal("mana_changed"):
		player.emit_signal("mana_changed", current_mana)


## Definir mana atual
func set_mana(amount: float) -> void:
	current_mana = clamp(amount, 0, max_mana)
	value = current_mana
	if player and player.has_signal("mana_changed"):
		player.emit_signal("mana_changed", current_mana)


## Definir mana máxima
func set_max_mana(amount: float) -> void:
	max_mana = amount
	max_value = max_mana
	current_mana = min(current_mana, max_mana)
	value = current_mana
	if player and player.has_signal("max_mana_changed"):
		player.emit_signal("max_mana_changed", max_mana)
