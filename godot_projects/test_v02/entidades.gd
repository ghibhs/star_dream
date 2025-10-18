extends CharacterBody2D

# -----------------------------
# MOVIMENTO / ANIMAÇÃO DO PLAYER
# -----------------------------
@export var speed: float = 150.0
var direction: Vector2 = Vector2.ZERO
var last_dir: Vector2 = Vector2.DOWN  # última direção não-nula pra orientar sprite/ataques

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(_delta: float) -> void:
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction != Vector2.ZERO:
		last_dir = direction.normalized()

	if direction != Vector2.ZERO:
		play_animations(direction)
	else:
		if animation:
			animation.stop()

	# Arma aponta pro mouse apenas se for projectile
	if current_weapon_data and current_weapon_data.weapon_type == "projectile" and weapon_marker:
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

	# garante cooldown por timer
	if weapon_timer and not weapon_timer.timeout.is_connected(_on_weapon_timer_timeout):
		weapon_timer.timeout.connect(_on_weapon_timer_timeout)
	weapon_timer.wait_time = 1.0 / fire_rate


func _process(_delta: float) -> void:
	# Só rotaciona pro mouse se for projectile; melee mantém marker "neutro"
	if current_weapon_data and current_weapon_data.weapon_type == "projectile":
		if weapon_marker:
			weapon_marker.rotation = weapon_marker.rotation # (no-op, já setado no _physics_process)
	else:
		if weapon_marker:
			weapon_marker.rotation = 0.0

	# Atualiza flip (x<0) e tilt do sprite da arma
	update_weapon_sprite_direction()


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
	create_or_update_weapon_sprite()
	setup_attack_area()
	setup_projectile_spawn()
	update_weapon_sprite_direction()


func create_or_update_weapon_sprite() -> void:
	# Se por algum motivo não existir, criamos um novo e anexamos ao marker.
	if current_weapon_sprite == null:
		current_weapon_sprite = AnimatedSprite2D.new()
		if weapon_marker:
			weapon_marker.add_child(current_weapon_sprite)

	# Atualiza frames e animação idle/loop
	if current_weapon_data.sprite_frames:
		current_weapon_sprite.sprite_frames = current_weapon_data.sprite_frames
	if current_weapon_data.animation_name != "":
		current_weapon_sprite.play(current_weapon_data.animation_name)

	# (Opcional) posição/escala definidas no recurso
	if current_weapon_data.Sprite_scale != Vector2.ZERO:
		current_weapon_sprite.scale = current_weapon_data.Sprite_scale
	if current_weapon_data.sprite_position != Vector2.ZERO:
		current_weapon_sprite.position = current_weapon_data.sprite_position


func setup_attack_area() -> void:
	# Limpa hitbox antiga (se existir)
	if attack_area and is_instance_valid(attack_area):
		attack_area.queue_free()
		attack_area = null

	# Cria hitbox apenas se a arma possuir colisão de melee
	if current_weapon_data and current_weapon_data.attack_collision:
		attack_area = Area2D.new()
		var collision_shape := CollisionShape2D.new()
		collision_shape.shape = current_weapon_data.attack_collision
		attack_area.add_child(collision_shape)

		# Coloca a hitbox como filha do marker da arma (move junto naturalmente)
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

	match current_weapon_data.weapon_type:
		"melee":
			melee_attack()
		"projectile":
			projectile_attack()
		_:
			melee_attack()  # fallback


func melee_attack() -> void:
	if not attack_area:
		print("no attack area")
		return

	# toca animação do golpe na arma (se configurada)
	if current_weapon_sprite and current_weapon_data.melee_anim_name != "":
		current_weapon_sprite.play(current_weapon_data.melee_anim_name)

	# decide chave de direção pra pegar offsets
	var key := _dir_key_from_vector(last_dir)
	var cfg = current_weapon_data.hitbox_offsets.get(key, null)
	if cfg == null:
		cfg = current_weapon_data.hitbox_offsets.get("down")

	# posiciona início e liga a hitbox
	attack_area.position = cfg.start
	attack_area.rotation = 0.0
	attack_area.monitoring = true

	# tween: move a hitbox do start pro end no tempo do golpe
	var t := create_tween()
	t.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(attack_area, "position", cfg.end, current_weapon_data.melee_swing_time)

	await t.finished

	# desliga a hitbox após o swing
	attack_area.monitoring = false

	# inicia cooldown
	can_attack = false
        # para a animação de ataque da espada após o golpe
        if current_weapon_sprite:
            if current_weapon_data and current_weapon_data.animation_name != "":
                current_weapon_sprite.play(current_weapon_data.animation_name)
            else:
                current_weapon_sprite.stop()

	if weapon_timer:
		weapon_timer.wait_time = 1.0 / fire_rate
		weapon_timer.start()


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

	# cooldown
	can_attack = false
	if weapon_timer:
		weapon_timer.wait_time = 1.0 / fire_rate
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


func _on_weapon_timer_timeout() -> void:
	can_attack = true


func update_weapon_sprite_direction() -> void:
	if not current_weapon_sprite or not current_weapon_data:
		return

	# inverter quando estiver olhando "pra esquerda" (x < 0)
	var looking_left := last_dir.x < 0.0
	if current_weapon_data.sprite_flip_on_left:
		current_weapon_sprite.flip_h = looking_left

	# tilt: inclina um pouco quando olhando pra esquerda (se quiser sempre, remova o if)
	if looking_left:
		current_weapon_sprite.rotation = deg_to_rad(current_weapon_data.sprite_tilt_deg)
	else:
		current_weapon_sprite.rotation = 0.0

	# (opcional) reforça posição/escala do .tres
	if current_weapon_data.sprite_position != Vector2.ZERO:
		current_weapon_sprite.position = current_weapon_data.sprite_position
	if current_weapon_data.Sprite_scale != Vector2.ZERO:
		current_weapon_sprite.scale = current_weapon_data.Sprite_scale


func _dir_key_from_vector(v: Vector2) -> String:
	var d := v.normalized()
	# thresholds simples pras diagonais
	if d.y < -0.5 and d.x > 0.5:
		return "up_right"
	elif d.y < -0.5 and d.x < -0.5:
		return "up_left"
	elif d.y > 0.5 and d.x > 0.5:
		return "down_right"
	elif d.y > 0.5 and d.x < -0.5:
		return "down_left"
	elif abs(d.x) > abs(d.y):
		return "right" if d.x > 0.0 else "left"
	else:
		return "down" if d.y > 0.0 else "up"
