extends CharacterBody2D

# -----------------------------
# MOVIMENTO / ANIMAÇÃO DO PLAYER
# -----------------------------
@export var speed: float = 100.0
var direction: Vector2 = Vector2.ZERO

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
		# offset opcional, se o sprite “aponta” para cima/direita diferente do seu:
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
@onready var current_weapon_sprite: AnimatedSprite2D = $WeaponMarker2D/WeaponAnimatedSprite2D
@export var fire_rate: float = 3.0  # tiros por segundo (cd = 1 / fire_rate)
var can_attack: bool = true

var attack_area: Area2D

func _ready() -> void:
	add_to_group("player")

func _process(_delta: float) -> void:
	if current_weapon_data.weapon_type == "projectile":
		weapon_marker.look_at(get_global_mouse_position())
		if weapon_angle_offset_deg != 0.0:
			weapon_marker.rotation += deg_to_rad(weapon_angle_offset_deg)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		can_attack = true
		if weapon_timer.is_stopped():
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
	create_or_update_weapon_sprite()
	setup_attack_area()
	setup_projectile_spawn()


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
	# Caso contrário, você pode continuar ajustando a escala desse nó no editor à vontade.


func setup_attack_area() -> void:
	# Limpa hitbox antiga (se existir)
	if attack_area and is_instance_valid(attack_area):
		attack_area.queue_free()
		attack_area = null

	# Cria hitbox apenas se a arma possuir colisão de melee
	if current_weapon_data.attack_collision:
		attack_area = Area2D.new()
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

	# --- dispara conforme o tipo ---
	match current_weapon_data.weapon_type:
		"melee":
			melee_attack()
		"projectile":
			projectile_attack()
		_:
			melee_attack()  # fallback


func melee_attack() -> void:
	if not attack_area:
		return
	attack_area.monitoring = true
	await get_tree().create_timer(0.2).timeout
	attack_area.monitoring = false


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
	weapon_timer.start()

func _on_attack_hit(body: Node) -> void:
	if body.is_in_group("enemies"):
		apply_damage_to_target(body)


func apply_damage_to_target(target: Node) -> void:
	if current_weapon_data == null:
		return
	if target.has_method("take_damage"):
		target.take_damage(current_weapon_data.damage)
		print("Dano aplicado: ", current_weapon_data.damage)
