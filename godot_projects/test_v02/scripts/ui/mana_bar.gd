# ManaBar.gd
extends ProgressBar

@onready var player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	# Aguarda o player estar pronto
	await get_tree().process_frame
	
	player = get_tree().get_first_node_in_group("player")
	
	if not player:
		print("[MANA_BAR] ❌ Player não encontrado!")
		return
	
	print("[MANA_BAR] ✅ Player encontrado: ", player.name)
	
	# Conectar aos sinais do player
	if player.has_signal("mana_changed"):
		player.mana_changed.connect(_on_mana_changed)
		print("[MANA_BAR] ✅ Conectado ao sinal mana_changed")
	else:
		print("[MANA_BAR] ❌ Sinal mana_changed não existe no player!")
	
	if player.has_signal("max_mana_changed"):
		player.max_mana_changed.connect(_on_max_mana_changed)
		print("[MANA_BAR] ✅ Conectado ao sinal max_mana_changed")
	
	# Sincroniza valores iniciais do player
	max_value = player.max_mana
	value = player.current_mana
	print("[MANA_BAR] Max mana: %.1f" % max_value)
	print("[MANA_BAR] Current mana: %.1f" % value)
	
	# Estilo da barra
	modulate = Color(0.2, 0.5, 1.0)  # Azul para mana


func _on_mana_changed(new_mana: float) -> void:
	value = new_mana
	print("[MANA_BAR] 🔮 Mana atualizada: %.1f/%.1f" % [new_mana, max_value])


func _on_max_mana_changed(new_max_mana: float) -> void:
	max_value = new_max_mana
	print("[MANA_BAR] 📊 Max mana atualizada: %.1f" % new_max_mana)
