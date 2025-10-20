extends CharacterBody2D

# -----------------------------
# MOVIMENTO / ANIMAÇÃO DO PLAYER
# -----------------------------
@export var speed: float = 150.0
@export var sprint_multiplier: float = 1.8  # Multiplicador de velocidade no sprint
@export var dash_speed: float = 500.0  # Velocidade do dash
@export var dash_duration: float = 0.15  # Duração do dash em segundos
@export var dash_cooldown: float = 1.0  # Cooldown entre dashes em segundos

var direction: Vector2 = Vector2.ZERO
var is_sprinting: bool = false
var is_dashing: bool = false
var can_dash: bool = true
var dash_direction: Vector2 = Vector2.ZERO

# Timers para dash
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0

# -----------------------------
# SISTEMA DE SAÚDE DO PLAYER
# -----------------------------
@export var max_health: float = 100.0
var current_health: float
var is_dead: bool = false

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Atualiza timers
	update_dash_timers(delta)
	
	# Input de movimento
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Sprint (segurar Shift)
	is_sprinting = Input.is_action_pressed("sprint") and direction != Vector2.ZERO
	
	# Dash (pressionar Space)
	if Input.is_action_just_pressed("dash") and can_dash and direction != Vector2.ZERO:
		start_dash()
	
	# Animações
	if direction != Vector2.ZERO and not is_dashing:
		play_animations(direction)
	else:
		if animation and not is_dashing:
			animation.stop()

	# Arma aponta pro mouse (caso já tenha arma equipada)
	if current_weapon_data and weapon_marker:
		weapon_marker.look_at(get_global_mouse_position())
		# offset opcional, se o sprite "aponta" para cima/direita diferente do seu:
		if weapon_angle_offset_deg != 0.0:
			weapon_marker.rotation += deg_to_rad(weapon_angle_offset_deg)

	# Calcula velocidade final
	var final_velocity: Vector2
	
	if is_dashing:
		# Durante dash, movimento rápido na direção do dash
		final_velocity = dash_direction * dash_speed
	else:
		# Movimento normal com sprint
		var current_speed = speed
		if is_sprinting:
			current_speed *= sprint_multiplier
		final_velocity = direction * current_speed
	
	velocity = final_velocity
	move_and_slide()


func play_animations(dir: Vector2) -> void:
	if not animation:
		return

	# Seu mapeamento atual de animações (ajuste os nomes se quiser)
	if dir.x > 0 and dir.y == 0:
		animation.play("default")            # → direita
	elif dir.x < 0 and dir.y == 0:
		animation.play("new_animation_3")    # ← esquerda
	elif dir.x == 0 and dir.y < 0:
		animation.play("new_animation_1")    # ↑ cima
	elif dir.x == 0 and dir.y > 0:
		animation.play("new_animation_5")    # ↓ baixo
	elif dir.x > 0 and dir.y < 0:
		animation.play("new_animation")      # ↗
	elif dir.x < 0 and dir.y < 0:
		animation.play("new_animation_2")    # ↖
	elif dir.x < 0 and dir.y > 0:
		animation.play("new_animation_4")    # ↙
	elif dir.x > 0 and dir.y > 0:
		animation.play("new_animation_6")    # ↘


# -----------------------------
# SISTEMA DE SPRINT E DASH
# -----------------------------
func update_dash_timers(delta: float) -> void:
	"""Atualiza os timers do dash"""
	# Timer de duração do dash
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			end_dash()
	
	# Timer de cooldown do dash
	if not can_dash:
		dash_cooldown_timer -= delta
		if dash_cooldown_timer <= 0.0:
			can_dash = true
			print("[PLAYER] 🔄 Dash disponível novamente!")


func start_dash() -> void:
	"""Inicia o dash"""
	if is_dashing or not can_dash:
		return
	
	print("[PLAYER] 💨 DASH iniciado!")
	is_dashing = true
	can_dash = false
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown
	dash_direction = direction.normalized()
	
	# Efeito visual (opcional): pode adicionar partículas ou animação especial aqui


func end_dash() -> void:
	"""Finaliza o dash"""
	print("[PLAYER] ✅ Dash finalizado")
	is_dashing = false
	dash_timer = 0.0


# -----------------------------
# ARMA / ATAQUE
# -----------------------------
# -----------------------------
# ARMA DO PLAYER
# -----------------------------
var current_weapon_data: WeaponData
@export var weapon_item_scene: PackedScene = preload("res://scenes/items/bow.tscn")  # Cena genérica do item

@export var weapon_angle_offset_deg: float = 0.0   # ajuste fino da rotação do sprite da arma
@onready var weapon_marker: Node2D = $WeaponMarker2D
@onready var projectile_spawn_marker: Marker2D = $WeaponMarker2D/ProjectileSpawnMarker2D
@onready var weapon_timer: Timer = $WeaponMarker2D/Weapon_timer
# IMPORTANTE: Após mover WeaponAnimatedSprite2D para dentro do WeaponMarker2D no editor:
@onready var current_weapon_sprite: AnimatedSprite2D = $WeaponMarker2D/WeaponAnimatedSprite2D
@export var fire_rate: float = 3.0  # tiros por segundo (cd = 1 / fire_rate)
var can_attack: bool = true

var attack_area: Area2D

func _ready() -> void:
	add_to_group("player")
	print("[PLAYER] Inicializado e adicionado ao grupo 'player'")
	print("[PLAYER]    Nome do node: ", name)
	print("[PLAYER]    Tipo: ", get_class())
	print("[PLAYER]    Collision Layer: ", collision_layer, " (binário: ", String.num_int64(collision_layer, 2), ")")
	print("[PLAYER]    Collision Mask: ", collision_mask, " (binário: ", String.num_int64(collision_mask, 2), ")")
	
	# Verifica CollisionShape2D
	var collision_shape = get_node_or_null("CollisionShape2D")
	if collision_shape:
		print("[PLAYER]    CollisionShape2D encontrado")
		print("[PLAYER]       Disabled: ", collision_shape.disabled)
		print("[PLAYER]       Shape: ", collision_shape.shape)
	else:
		print("[PLAYER]    ⚠️ CollisionShape2D NÃO encontrado!")
	
	# Inicializa saúde
	current_health = max_health
	print("[PLAYER] Saúde inicializada: %.1f/%.1f" % [current_health, max_health])
	
	# Inicia contagem de estatísticas
	if has_node("/root/GameStats"):
		get_node("/root/GameStats").start_game()
		print("[PLAYER] Sistema de estatísticas iniciado")
	
	# Configura timer de cooldown
	if weapon_timer:
		weapon_timer.wait_time = 1.0 / fire_rate
		weapon_timer.one_shot = true
		weapon_timer.timeout.connect(_on_weapon_timer_timeout)
		print("[PLAYER] Timer de ataque configurado: %.2fs cooldown" % weapon_timer.wait_time)
	# Armas melee não rotacionam para o mouse


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		print("[PLAYER] Tecla de ataque pressionada")
		if can_attack and weapon_timer.is_stopped():
			print("[PLAYER] Iniciando ataque...")
			perform_attack()
		else:
			if not can_attack:
				print("[PLAYER] ⚠️ Ataque bloqueado: can_attack = false")
			if not weapon_timer.is_stopped():
				print("[PLAYER] ⚠️ Ataque bloqueado: timer ainda ativo (%.2fs restantes)" % weapon_timer.time_left)


func receive_weapon_data(weapon_data: WeaponData) -> void:
	# Recebido do item coletável
	print("[PLAYER] 🗡️ Arma recebida: ", weapon_data.item_name)
	print("[PLAYER]    Tipo: ", weapon_data.weapon_type)
	print("[PLAYER]    Dano: ", weapon_data.damage)
	
	# ⚠️ NOVO: Se já temos uma arma equipada, dropa ela no mundo
	if current_weapon_data:
		print("[PLAYER] 🔄 Já existe arma equipada! Dropando arma antiga...")
		drop_current_weapon()
	
	# Equipa a nova arma
	current_weapon_data = weapon_data
	call_deferred("setup_weapon")


func drop_current_weapon() -> void:
	"""
	Dropa a arma atual no mundo próximo ao player
	"""
	if not current_weapon_data:
		print("[PLAYER] ⚠️ Tentou dropar arma mas não há arma equipada")
		return
	
	print("[PLAYER] 📦 Dropando arma: ", current_weapon_data.item_name)
	
	# Cria instância do item no mundo
	var dropped_item = weapon_item_scene.instantiate() as Area2D
	
	if dropped_item:
		# Posição de drop: um pouco à frente do player (na direção que ele está olhando)
		var drop_offset = Vector2(50, 0)  # 50 pixels à direita
		if direction != Vector2.ZERO:
			# Se o player está se movendo, dropa na direção oposta
			drop_offset = -direction.normalized() * 50
		
		dropped_item.global_position = global_position + drop_offset
		
		# ⚠️ IMPORTANTE: Configura o item ANTES de adicionar à árvore (evita glitch)
		dropped_item.initialize_dropped_item(current_weapon_data)
		
		# Adiciona ao mundo (mesma cena que o player)
		get_parent().add_child(dropped_item)
		
		print("[PLAYER]    ✅ Arma dropada na posição: ", dropped_item.global_position)
	else:
		push_error("[PLAYER] ❌ Falha ao instanciar item dropado")


func setup_weapon() -> void:
	if not current_weapon_data:
		print("[PLAYER] ⚠️ setup_weapon() chamado sem weapon_data")
		return

	print("[PLAYER] Configurando arma: ", current_weapon_data.item_name)
	# NÃO destruímos o sprite da arma — ele já está na cena para você poder editar escala no editor.
	# Apenas atualizamos os dados visuais e os pontos auxiliares.
	setup_weapon_marker_position()
	create_or_update_weapon_sprite()
	setup_attack_area()
	setup_projectile_spawn()
	print("[PLAYER] ✅ Arma configurada com sucesso")


func setup_weapon_marker_position() -> void:
	# Configura posição do weapon_marker (ponto de rotação da arma)
	if weapon_marker and current_weapon_data:
		if "weapon_marker_position" in current_weapon_data:
			weapon_marker.position = current_weapon_data.weapon_marker_position
		else:
			weapon_marker.position = Vector2.ZERO  # Posição padrão


func create_or_update_weapon_sprite() -> void:
	# Se por algum motivo não existir, criamos um novo e anexamos ao marker.
	if current_weapon_sprite == null:
		current_weapon_sprite = AnimatedSprite2D.new()
		if weapon_marker:
			weapon_marker.add_child(current_weapon_sprite)
	# Atualiza frames e animação
	if current_weapon_data.sprite_frames:
		current_weapon_sprite.sprite_frames = current_weapon_data.sprite_frames
	if current_weapon_data.animation_name != "":
		current_weapon_sprite.play(current_weapon_data.animation_name)

	# (Opcional) se seu Resource tiver um campo de escala da arma:
	if "Sprite_scale" in current_weapon_data and current_weapon_data.Sprite_scale != Vector2.ZERO:
		current_weapon_sprite.scale = current_weapon_data.Sprite_scale
		print("scale: ",current_weapon_sprite.scale)
		
	if "sprite_position" in current_weapon_data and current_weapon_data.sprite_position != Vector2.ZERO:
		current_weapon_sprite.position = current_weapon_data.sprite_position
	# Caso contrário, você pode continuar ajustando a escala desse nó no editor à vontade.
	

func setup_attack_area() -> void:
	# Limpa hitbox antiga (se existir)
	if attack_area and is_instance_valid(attack_area):
		print("[PLAYER] Removendo hitbox antiga")
		attack_area.queue_free()
		attack_area = null

	# Cria hitbox apenas se a arma possuir colisão de melee
	if current_weapon_data.attack_collision:
		print("[PLAYER] Criando hitbox de melee...")
		attack_area = Area2D.new()
		attack_area.collision_layer = 16  # Layer 5: Player Hitbox
		attack_area.collision_mask = 4    # Mask 3: Detecta Enemy
		
		# 🗡️ HITBOX DE ATAQUE: Configurável via WeaponData.tres
		var collision_shape := CollisionShape2D.new()
		
		# Usa shape do .tres ou cria padrão
		if "attack_hitbox_shape" in current_weapon_data and current_weapon_data.attack_hitbox_shape:
			collision_shape.shape = current_weapon_data.attack_hitbox_shape
			print("[PLAYER]    ✅ Usando attack_hitbox_shape do .tres")
		else:
			# Fallback: cria forma baseada no tipo de arma
			var attack_shape = RectangleShape2D.new()
			if current_weapon_data.weapon_type == "melee":
				attack_shape.size = Vector2(40, 15)  # Linha de corte
			else:
				attack_shape.size = Vector2(25, 25)
			collision_shape.shape = attack_shape
			print("[PLAYER]    ⚠️ attack_hitbox_shape não definido, usando padrão")
		
		attack_area.add_child(collision_shape)
		
		# Usa offset do .tres
		if "attack_hitbox_offset" in current_weapon_data:
			attack_area.position = current_weapon_data.attack_hitbox_offset
			print("[PLAYER]    Hitbox offset: ", current_weapon_data.attack_hitbox_offset)
		elif "attack_collision_position" in current_weapon_data:
			attack_area.position = current_weapon_data.attack_collision_position
			print("[PLAYER]    Hitbox position (fallback): ", current_weapon_data.attack_collision_position)
		else:
			attack_area.position = Vector2(30, 0)
			print("[PLAYER]    Hitbox position: Vector2(30, 0) - padrão")
		
		# 🎨 DEBUG VISUAL: Usa cor do .tres
		if "attack_hitbox_color" in current_weapon_data:
			collision_shape.debug_color = current_weapon_data.attack_hitbox_color
		else:
			collision_shape.debug_color = Color(0, 1, 0, 0.9)

		# Coloca a hitbox como filha do marker da arma
		if weapon_marker:
			weapon_marker.add_child(attack_area)
		
		print("[PLAYER]    Hitbox shape: ", current_weapon_data.attack_collision)
		print("[PLAYER]    Layer: 16, Mask: 4")

		# Conexões e estado
		attack_area.body_entered.connect(_on_attack_hit)
		attack_area.monitoring = false  # fica off; liga durante o golpe


func setup_projectile_spawn() -> void:
	if projectile_spawn_marker and current_weapon_data:
		# Offset configurável no recurso
		projectile_spawn_marker.position = current_weapon_data.projectile_spawn_offset


func perform_attack() -> void:
	if not current_weapon_data:
		print("[PLAYER] ⚠️ Tentou atacar sem arma equipada")
		return
	if not can_attack:
		print("[PLAYER] ⚠️ Ataque bloqueado: ainda em cooldown")
		return  # ainda em cooldown
	
	print("[PLAYER] ⚔️ ATACANDO com ", current_weapon_data.item_name)
	print("[PLAYER]    Tipo: ", current_weapon_data.weapon_type)
	
	# Desabilita ataques durante cooldown
	can_attack = false

	# --- dispara conforme o tipo ---
	match current_weapon_data.weapon_type:
		"melee":
			print("[PLAYER]    → Executando ataque melee")
			melee_attack()
		"projectile":
			print("[PLAYER]    → Disparando projétil")
			projectile_attack()
		_:
			print("[PLAYER]    → Tipo desconhecido, usando melee como fallback")
			melee_attack()  # fallback
	
	# Inicia cooldown
	if weapon_timer:
		weapon_timer.wait_time = 1.0 / fire_rate
		weapon_timer.start()
		print("[PLAYER]    Cooldown iniciado: %.2fs" % weapon_timer.wait_time)


func melee_attack() -> void:
	if not attack_area:
		print("[PLAYER] ⚠️ Ataque melee cancelado: attack_area não existe")
		return
	
	print("[PLAYER] 🗡️ Executando ataque melee...")
	
	# 🎯 DIRECIONA a hitbox para o mouse
	if attack_area:
		var direction_to_mouse = (get_global_mouse_position() - global_position).normalized()
		var angle_to_mouse = direction_to_mouse.angle()
		
		# Rotaciona a hitbox para apontar ao mouse
		attack_area.rotation = angle_to_mouse
		print("[PLAYER]    🎯 Hitbox rotacionada para o mouse (%.1f graus)" % rad_to_deg(angle_to_mouse))
	
	# Toca animação de ataque baseada na posição do mouse
	if current_weapon_sprite and current_weapon_data:
		# Calcula posição X do mouse em relação ao player
		var mouse_pos_x = get_global_mouse_position().x - global_position.x
		
		# Escolhe animação baseada na posição X do mouse
		var attack_animation = ""
		if mouse_pos_x < 0:
			# Mouse à esquerda
			attack_animation = "attack_left"
			print("[PLAYER]    Direção: ESQUERDA (mouse_x: %.1f)" % mouse_pos_x)
		else:
			# Mouse à direita
			attack_animation = "attack_right"
			print("[PLAYER]    Direção: DIREITA (mouse_x: %.1f)" % mouse_pos_x)

		# Toca a animação se existir
		if current_weapon_data.sprite_frames.has_animation(attack_animation):
			current_weapon_sprite.play(attack_animation)
			print("[PLAYER]    ✅ Animação: ", attack_animation)
		elif current_weapon_data.sprite_frames.has_animation("attack"):
			# Fallback para "attack" se as novas animações não existirem
			current_weapon_sprite.play("attack")
			print("[PLAYER]    ⚠️ Usando animação fallback: 'attack'")
	
	# Ativa hitbox
	attack_area.monitoring = true
	print("[PLAYER]    Hitbox de GOLPE ATIVADA!")
	
	# 🎨 VISUAL: Deixa o golpe BEM visível
	for child in attack_area.get_children():
		if child is CollisionShape2D:
			child.debug_color = Color(0, 1, 0, 0.95)  # Verde muito brilhante
	
	# ⚡ Usa duração configurada no .tres
	var attack_hit_duration = 0.1
	if "attack_hitbox_duration" in current_weapon_data:
		attack_hit_duration = current_weapon_data.attack_hitbox_duration
		print("[PLAYER]    ⏱️ Duração do golpe: %.2fs (do .tres)" % attack_hit_duration)
	else:
		print("[PLAYER]    ⏱️ Duração do golpe: %.2fs (padrão)" % attack_hit_duration)
	
	await get_tree().create_timer(attack_hit_duration).timeout
	
	# Desativa hitbox
	attack_area.monitoring = false
	print("[PLAYER]    Hitbox de GOLPE DESATIVADA!")
	
	# 🎨 VISUAL: Esconde o golpe
	for child in attack_area.get_children():
		if child is CollisionShape2D:
			child.debug_color = Color(0, 1, 0, 0.0)  # Invisível
	
	# Volta para animação idle/default
	if current_weapon_sprite and current_weapon_data:
		if current_weapon_data.animation_name != "":
			current_weapon_sprite.play(current_weapon_data.animation_name)
			print("[PLAYER]    Voltando para animação: ", current_weapon_data.animation_name)
		else:
			current_weapon_sprite.stop()
			print("[PLAYER]    Sprite parado (sem animação idle)")


func projectile_attack() -> void:
	print("[PLAYER] 🏹 Disparando projétil...")
	var scene := preload("res://scenes/projectiles/projectile.tscn")
	if not scene or not projectile_spawn_marker:
		print("[PLAYER] ⚠️ Projétil cancelado: scene ou spawn_marker inválido")
		return

	var projectile := scene.instantiate()
	projectile.global_position = projectile_spawn_marker.global_position
	print("[PLAYER]    Spawn position: ", projectile_spawn_marker.global_position)

	# Entra na árvore primeiro para garantir que _ready/@onready do projétil rodem
	get_tree().current_scene.add_child(projectile)
	print("[PLAYER]    Projétil adicionado à cena")

	# Direção para o mouse
	var dir: Vector2 = (get_global_mouse_position() - projectile.global_position).normalized()
	print("[PLAYER]    Direção: ", dir)

	# Passa os dados DEPOIS (deferred) — evita Nil no AnimatedSprite2D do projétil
	projectile.call_deferred("setup_from_weapon_data", current_weapon_data, dir)
	print("[PLAYER]    ✅ Projétil configurado e disparado")


func _on_attack_hit(body: Node) -> void:
	print("[PLAYER] 💥 Hitbox colidiu com: ", body.name)
	print("[PLAYER]    Grupos: ", body.get_groups())
	if body.is_in_group("enemies"):
		print("[PLAYER]    ✅ É um inimigo! Aplicando dano...")
		apply_damage_to_target(body)
	else:
		print("[PLAYER]    ⚠️ Não é um inimigo, ignorando")


func apply_damage_to_target(target: Node) -> void:
	if current_weapon_data == null:
		print("[PLAYER] ⚠️ Dano cancelado: sem arma equipada")
		return
	if target.has_method("take_damage"):
		print("[PLAYER] 💥 Causando %.1f de dano em %s" % [current_weapon_data.damage, target.name])
		target.take_damage(current_weapon_data.damage)
		print("[PLAYER]    ✅ Dano aplicado com sucesso")
	else:
		print("[PLAYER]    ⚠️ Alvo não tem método take_damage()")


func _on_weapon_timer_timeout() -> void:
	can_attack = true
	print("[PLAYER] ⏱️ Cooldown terminado, can_attack = true")


# ===== SISTEMA DE SAÚDE =====
func _ready_health() -> void:
	current_health = max_health


func take_damage(amount: float) -> void:
	if is_dead:
		print("[PLAYER] ⚠️ Dano ignorado: player já está morto")
		return
	
	current_health -= amount
	print("[PLAYER] 💔 DANO RECEBIDO: %.1f" % amount)
	print("[PLAYER]    HP atual: %.1f/%.1f (%.1f%%)" % [current_health, max_health, (current_health/max_health)*100])
	
	# Visual de dano (flash)
	apply_hit_flash()
	
	# Verifica morte
	if current_health <= 0:
		print("[PLAYER] ☠️ HP chegou a 0, iniciando morte...")
		die()


func apply_hit_flash() -> void:
	print("[PLAYER]    🔴 Aplicando flash vermelho")
	if animation:
		animation.modulate = Color(1, 0.3, 0.3)  # Vermelho
		await get_tree().create_timer(0.1).timeout
		animation.modulate = Color(1, 1, 1)  # Volta ao normal
		print("[PLAYER]    ✅ Flash terminado")


func die() -> void:
	is_dead = true
	print("[PLAYER] ☠️☠️☠️ PLAYER MORREU! ☠️☠️☠️")
	print("[PLAYER]    Physics desativado")
	
	# Para o movimento
	set_physics_process(false)
	velocity = Vector2.ZERO
	
	# Para estatísticas
	if has_node("/root/GameStats"):
		get_node("/root/GameStats").stop_game()
	
	# Aguarda um pouco antes de mostrar a tela de Game Over
	await get_tree().create_timer(1.5).timeout
	
	# Carrega e mostra a tela de Game Over
	show_game_over()


func show_game_over() -> void:
	print("[PLAYER] 📺 Mostrando tela de Game Over")
	print("[PLAYER] 🔄 VERSÃO NOVA - Trocando cena inteira (não add_child)")
	
	# Para o jogo (já está pausado pelo die())
	if has_node("/root/GameStats"):
		get_node("/root/GameStats").stop_game()
		print("[PLAYER]    GameStats.stop_game() chamado")
	
	# Aguarda um frame para garantir que tudo foi processado
	print("[PLAYER]    Aguardando 1 frame...")
	await get_tree().process_frame
	print("[PLAYER]    Frame processado, iniciando troca de cena")
	
	# TROCA a cena para o Game Over (não adiciona como filho!)
	var game_over_path = "res://scenes/ui/game_over.tscn"
	
	if ResourceLoader.exists(game_over_path):
		print("[PLAYER]    Arquivo encontrado: ", game_over_path)
		print("[PLAYER]    Chamando change_scene_to_file()...")
		get_tree().change_scene_to_file(game_over_path)
		print("[PLAYER] ✅ change_scene_to_file() executado!")
	else:
		push_error("Não foi possível encontrar: " + game_over_path)
		print("[PLAYER] ❌ ERRO: Arquivo não encontrado!")
