extends CharacterBody2D

# -----------------------------
# MOVIMENTO / ANIMAÇÃO DO PLAYER
# -----------------------------
@export var speed: float = 150.0
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
	
	# Inicializa saúde
	current_health = max_health
	
	# Configura timer de cooldown
	if weapon_timer:
		weapon_timer.wait_time = 1.0 / fire_rate
		weapon_timer.one_shot = true
		weapon_timer.timeout.connect(_on_weapon_timer_timeout)
	# Armas melee não rotacionam para o mouse


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		if can_attack and weapon_timer.is_stopped():
			perform_attack()


func receive_weapon_data(weapon_data: Weapon_Data) -> void:
	# Recebido do item coletável
	print("Arma recebida: ", weapon_data.item_name)
	current_weapon_data = weapon_data
	call_deferred("setup_weapon")


func setup_weapon() -> void:
	if not current_weapon_data:
		return

	# NÃO destruímos o sprite da arma — ele já está na cena para você poder editar escala no editor.
	# Apenas atualizamos os dados visuais e os pontos auxiliares.
	setup_weapon_marker_position()
	create_or_update_weapon_sprite()
	setup_attack_area()
	setup_projectile_spawn()


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
		attack_area.queue_free()
		attack_area = null

	# Cria hitbox apenas se a arma possuir colisão de melee
	if current_weapon_data.attack_collision:
		attack_area = Area2D.new()
		attack_area.collision_layer = 16  # Layer 5: Player Hitbox
		attack_area.collision_mask = 4    # Mask 3: Detecta Enemy
		
		var collision_shape := CollisionShape2D.new()
		collision_shape.shape = current_weapon_data.attack_collision
		attack_area.add_child(collision_shape)

		# Coloca a hitbox como filha do marker da arma
		if weapon_marker:
			weapon_marker.add_child(attack_area)

		# Conexões e estado
		attack_area.body_entered.connect(_on_attack_hit)
		attack_area.monitoring = false  # fica off; liga durante o golpe


func setup_projectile_spawn() -> void:
	if projectile_spawn_marker and current_weapon_data:
		# Offset configurável no recurso
		projectile_spawn_marker.position = current_weapon_data.projectile_spawn_offset


func perform_attack() -> void:
	if not current_weapon_data:
		return
	if not can_attack:
		return  # ainda em cooldown
	
	# Desabilita ataques durante cooldown
	can_attack = false

	# --- dispara conforme o tipo ---
	match current_weapon_data.weapon_type:
		"melee":
			melee_attack()
		"projectile":
			projectile_attack()
		_:
			melee_attack()  # fallback
	
	# Inicia cooldown
	if weapon_timer:
		weapon_timer.wait_time = 1.0 / fire_rate
		weapon_timer.start()


func melee_attack() -> void:
	if not attack_area:
		print("no attack area")
		return
	
	# Toca animação de ataque baseada na posição do mouse
	if current_weapon_sprite and current_weapon_data:
		# Calcula posição X do mouse em relação ao player
		var mouse_pos_x = get_global_mouse_position().x - global_position.x
		
		# Escolhe animação baseada na posição X do mouse
		var attack_animation = ""
		if mouse_pos_x < 0:
			# Mouse à esquerda
			attack_animation = "attack_left"
			print("ataque esquerda")
		else:
			# Mouse à direita
			attack_animation = "attack_right"
			print("ataque direita")

		# Toca a animação se existir
		if current_weapon_data.sprite_frames.has_animation(attack_animation):
			current_weapon_sprite.play(attack_animation)
		elif current_weapon_data.sprite_frames.has_animation("attack"):
			# Fallback para "attack" se as novas animações não existirem
			current_weapon_sprite.play("attack")
	
	# Ativa hitbox
	attack_area.monitoring = true
	await get_tree().create_timer(0.2).timeout
	
	# Desativa hitbox
	attack_area.monitoring = false
	
	# Volta para animação idle/default
	if current_weapon_sprite and current_weapon_data:
		if current_weapon_data.animation_name != "":
			current_weapon_sprite.play(current_weapon_data.animation_name)
		else:
			current_weapon_sprite.stop()


func projectile_attack() -> void:
	var scene := preload("res://projectile.tscn")
	if not scene or not projectile_spawn_marker:
		return

	var projectile := scene.instantiate()
	projectile.global_position = projectile_spawn_marker.global_position

	# Entra na árvore primeiro para garantir que _ready/@onready do projétil rodem
	get_tree().current_scene.add_child(projectile)

	# Direção para o mouse
	var dir: Vector2 = (get_global_mouse_position() - projectile.global_position).normalized()

	# Passa os dados DEPOIS (deferred) — evita Nil no AnimatedSprite2D do projétil
	projectile.call_deferred("setup_from_weapon_data", current_weapon_data, dir)


func _on_attack_hit(body: Node) -> void:
	if body.is_in_group("enemies"):
		apply_damage_to_target(body)


func apply_damage_to_target(target: Node) -> void:
	if current_weapon_data == null:
		return
	if target.has_method("take_damage"):
		target.take_damage(current_weapon_data.damage)
		print("Dano aplicado: ", current_weapon_data.damage)


func _on_weapon_timer_timeout() -> void:
	can_attack = true


# ===== SISTEMA DE SAÚDE =====
func _ready_health() -> void:
	current_health = max_health


func take_damage(amount: float) -> void:
	if is_dead:
		return
	
	current_health -= amount
	print("Player tomou %.1f de dano! HP: %.1f/%.1f" % [amount, current_health, max_health])
	
	# Visual de dano (flash)
	apply_hit_flash()
	
	# Verifica morte
	if current_health <= 0:
		die()


func apply_hit_flash() -> void:
	if animation:
		animation.modulate = Color(1, 0.3, 0.3)  # Vermelho
		await get_tree().create_timer(0.1).timeout
		animation.modulate = Color(1, 1, 1)  # Volta ao normal


func die() -> void:
	is_dead = true
	print("Player morreu!")
	# TODO: Adicionar animação de morte, game over screen, etc.
	# Por enquanto só para o movimento
	set_physics_process(false)
