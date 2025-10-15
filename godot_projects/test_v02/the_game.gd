extends Node2D

func _ready() -> void:
	# Dica: garanta que o Player está em "player" group pela própria cena do player,
	# mas aqui dá pra achar o player e centralizar camera etc.
	var player := get_tree().get_first_node_in_group("player")
	if player:
		print("Player pronto")
