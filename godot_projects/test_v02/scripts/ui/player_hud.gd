# player_hud.gd
extends CanvasLayer

# ===== REFERÊNCIAS DOS ELEMENTOS DA HUD =====
@onready var health_bar: ProgressBar = $MarginContainer/VBoxContainer/HealthBar
@onready var health_label: Label = $MarginContainer/VBoxContainer/HealthBar/HealthLabel

@onready var weapon_name_label: Label = $MarginContainer/VBoxContainer/WeaponInfo/WeaponName
@onready var weapon_icon: TextureRect = $MarginContainer/VBoxContainer/WeaponInfo/WeaponIcon

@onready var speed_label: Label = $MarginContainer/VBoxContainer/StatsContainer/SpeedLabel
@onready var damage_label: Label = $MarginContainer/VBoxContainer/StatsContainer/DamageLabel
@onready var attack_speed_label: Label = $MarginContainer/VBoxContainer/StatsContainer/AttackSpeedLabel
@onready var dash_label: Label = $MarginContainer/VBoxContainer/StatsContainer/DashLabel

# ===== REFERÊNCIA AO PLAYER =====
var player: CharacterBody2D = null


func _ready() -> void:
	print("[PLAYER_HUD] HUD do player inicializada")
	
	# Procura o player na cena
	await get_tree().process_frame  # Aguarda um frame para garantir que tudo está carregado
	find_player()
	
	if player:
		update_all_stats()


func find_player() -> void:
	"""Procura o player na árvore de cenas"""
	var players = get_tree().get_nodes_in_group("player")
	
	if players.size() > 0:
		player = players[0] as CharacterBody2D
		print("[PLAYER_HUD] Player encontrado: ", player.name)
		
		# Conecta sinais do player (se houver)
		# player.health_changed.connect(_on_player_health_changed)
	else:
		push_error("[PLAYER_HUD] ❌ Player não encontrado na cena!")


func _process(_delta: float) -> void:
	"""Atualiza HUD a cada frame"""
	if player and not player.is_dead:
		update_health()
		update_weapon_info()
		update_stats()


func update_all_stats() -> void:
	"""Atualiza todos os elementos da HUD de uma vez"""
	if not player:
		return
	
	update_health()
	update_weapon_info()
	update_stats()


func update_health() -> void:
	"""Atualiza barra de vida"""
	if not player or not health_bar or not health_label:
		return
	
	var current_hp = player.current_health
	var max_hp = player.max_health
	
	# Atualiza barra
	health_bar.max_value = max_hp
	health_bar.value = current_hp
	
	# Atualiza label
	health_label.text = "%d / %d HP" % [int(current_hp), int(max_hp)]
	
	# Muda cor da barra baseado na porcentagem de vida
	var hp_percent = (current_hp / max_hp) * 100.0
	
	if hp_percent > 60:
		health_bar.modulate = Color(0.2, 1.0, 0.2)  # Verde
	elif hp_percent > 30:
		health_bar.modulate = Color(1.0, 0.8, 0.0)  # Amarelo
	else:
		health_bar.modulate = Color(1.0, 0.2, 0.2)  # Vermelho


func update_weapon_info() -> void:
	"""Atualiza informações da arma equipada"""
	if not player or not weapon_name_label:
		return
	
	if player.current_weapon_data:
		var weapon = player.current_weapon_data
		weapon_name_label.text = weapon.item_name.to_upper()
		
		# Atualiza ícone da arma (se houver sprite)
		if weapon_icon and weapon.sprite_frames:
			# Pega o primeiro frame da animação como ícone
			var frames = weapon.sprite_frames
			if frames.has_animation(weapon.animation_name):
				var texture = frames.get_frame_texture(weapon.animation_name, 0)
				weapon_icon.texture = texture
				weapon_icon.visible = true
			else:
				weapon_icon.visible = false
		else:
			if weapon_icon:
				weapon_icon.visible = false
	else:
		weapon_name_label.text = "SEM ARMA"
		if weapon_icon:
			weapon_icon.visible = false


func update_stats() -> void:
	"""Atualiza estatísticas do player"""
	if not player:
		return
	
	# Velocidade (com indicador de sprint)
	if speed_label:
		var speed_text = "⚡ Velocidade: %.0f" % player.speed
		if player.is_sprinting:
			speed_text += " 🏃 SPRINT!"
		speed_label.text = speed_text
	
	# Dano (da arma equipada)
	if damage_label:
		if player.current_weapon_data:
			damage_label.text = "⚔️ Dano: %.0f" % player.current_weapon_data.damage
		else:
			damage_label.text = "⚔️ Dano: 0"
	
	# Velocidade de ataque
	if attack_speed_label:
		if player.current_weapon_data:
			attack_speed_label.text = "🗡️ Vel. Ataque: %.1fx" % player.current_weapon_data.attack_speed
		else:
			attack_speed_label.text = "🗡️ Vel. Ataque: 0x"
	
	# Dash status
	if dash_label:
		if player.is_dashing:
			dash_label.text = "💨 DASH ATIVO!"
			dash_label.modulate = Color(0.2, 1.0, 1.0)  # Ciano
		elif not player.can_dash:
			var time_left = player.dash_cooldown_timer
			dash_label.text = "💨 Dash: %.1fs" % time_left
			dash_label.modulate = Color(1.0, 0.5, 0.0)  # Laranja
		else:
			dash_label.text = "💨 Dash: PRONTO"
			dash_label.modulate = Color(0.2, 1.0, 0.2)  # Verde


func _on_player_health_changed(_new_health: float) -> void:
	"""Callback quando a vida do player muda (se implementar sinal)"""
	update_health()


func _on_player_weapon_changed(_new_weapon: Weapon_Data) -> void:
	"""Callback quando a arma do player muda (se implementar sinal)"""
	update_weapon_info()
	update_stats()
