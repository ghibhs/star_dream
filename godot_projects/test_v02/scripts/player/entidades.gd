extends CharacterBody2D

# -----------------------------
# MOVIMENTO / ANIMAÇÃO DO PLAYER
# -----------------------------
@export var speed: float = 150.0
@export var player_push_strength: float = 100.0  # Força de empurrão do jogador
var direction: Vector2 = Vector2.ZERO

# -----------------------------
# SISTEMA DE SAÚDE DO PLAYER
# -----------------------------
@export var max_health: float = 100.0
var current_health: float
var is_dead: bool = false

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(_delta: float) -> void:
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if direction != Vector2.ZERO:
		play_animations(direction)
	else:
		if animation:
			animation.stop()

	# Arma aponta pro mouse (caso já tenha arma equipada)
	if current_weapon_data and weapon_marker:
		weapon_marker.look_at(get_global_mouse_position())
		# offset opcional, se o sprite "aponta" para cima/direita diferente do seu:
		if weapon_angle_offset_deg != 0.0:
			weapon_marker.rotation += deg_to_rad(weapon_angle_offset_deg)

	velocity = direction * speed
	
	# Move e detecta colisões
	var collision_occurred = move_and_slide()
	
	# Sistema de empurrão de inimigos
	if collision_occurred:
		handle_enemy_push()


# -----------------------------
# SISTEMA DE EMPURRÃO DE INIMIGOS
# -----------------------------
func handle_enemy_push() -> void:
	# Verifica todas as colisões que ocorreram durante o movimento
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# Verifica se colidiu com um inimigo
		if collider and collider.is_in_group("enemies"):
			# Tenta pegar o enemy_data para verificar a resistência ao empurrão
			if collider.has_method("get_push_force"):
				var enemy_push_resistance = collider.get_push_force()
				
				# Se a força do jogador for maior que a resistência do inimigo, empurra
				if player_push_strength > enemy_push_resistance:
					var push_direction = (collider.global_position - global_position).normalized()
					var push_power = (player_push_strength - enemy_push_resistance) * 0.5
					
					# Aplica o empurrão no inimigo
					if collider.has_method("apply_push"):
						collider.apply_push(push_direction, push_power)


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
# ARMA / ATAQUE
# -----------------------------
var current_weapon_data: Weapon_Data

@export var weapon_angle_offset_deg: float = 0.0   # ajuste fino da rotação do sprite da arma
@onready var weapon_marker: Node2D = $WeaponMarker2D
@onready var projectile_spawn_marker: Marker2D = $WeaponMarker2D/ProjectileSpawnMarker2D
@onready var weapon_timer: Timer = $WeaponMarker2D/Weapon_timer
# IMPORTANTE: esse nó JÁ EXISTE na cena. Não vamos destruí-lo.
@onready var current_weapon_sprite: AnimatedSprite2D = $WeaponAnimatedSprite2D
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


func receive_weapon_data(weapon_data: Weapon_Data) -> void:
	# Recebido do item coletável
	print("[PLAYER] 🗡️ Arma recebida: ", weapon_data.item_name)
	print("[PLAYER]    Tipo: ", weapon_data.weapon_type)
	print("[PLAYER]    Dano: ", weapon_data.damage)
	current_weapon_data = weapon_data
	call_deferred("setup_weapon")


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
		
		# Aplica posição da hitbox definida no .tres
		if "attack_collision_position" in current_weapon_data:
			attack_area.position = current_weapon_data.attack_collision_position
			print("[PLAYER]    Hitbox position: ", current_weapon_data.attack_collision_position)
		else:
			attack_area.position = Vector2.ZERO
			print("[PLAYER]    ⚠️ attack_collision_position não definido, usando Vector2.ZERO")
		
		var collision_shape := CollisionShape2D.new()
		collision_shape.shape = current_weapon_data.attack_collision
		attack_area.add_child(collision_shape)

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
	print("[PLAYER]    Hitbox ATIVADA (monitoring = true)")
	await get_tree().create_timer(0.2).timeout
	
	# Desativa hitbox
	attack_area.monitoring = false
	print("[PLAYER]    Hitbox DESATIVADA (monitoring = false)")
	
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
	var scene := preload("res://projectile.tscn")
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
	
	var game_over_scene = load("res://game_over.tscn")
	if game_over_scene:
		var game_over_instance = game_over_scene.instantiate()
		get_tree().current_scene.add_child(game_over_instance)
		print("[PLAYER] ✅ Tela de Game Over adicionada")
	else:
		push_error("Não foi possível carregar game_over.tscn")
		print("[PLAYER] ❌ ERRO: game_over.tscn não encontrado")
