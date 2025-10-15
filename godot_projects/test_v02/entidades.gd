extends CharacterBody2D
class_name Player

@export var move_speed: float = 140.0

# Nós esperados na cena do Player:
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var weapon_marker: Marker2D = $WeaponMarker            # cria um Marker2D como filho do Player
@onready var attack_area: Area2D = $AttackArea                  # Area2D para ataque melee
@onready var attack_collision: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var projectile_spawn_marker: Marker2D = $ProjectileSpawn

# Timers
@onready var attack_cooldown: Timer = $AttackCooldown

# Dados da arma atual (Resource)
var current_weapon_data: Weapon_Data
var current_weapon_sprite: AnimatedSprite2D
var can_attack := true

func _ready() -> void:
	add_to_group("player")
	# Sinais
	if attack_area:
		attack_area.body_entered.connect(_on_attack_hit)
		attack_area.monitoring = false
	if attack_cooldown:
		attack_cooldown.one_shot = true

func _physics_process(delta: float) -> void:
	var dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = dir * move_speed
	move_and_slide()
	_update_animation(dir)

func _process(_delta: float) -> void:
	# Arma olha para o mouse
	if weapon_marker:
		weapon_marker.look_at(get_global_mouse_position())
		if current_weapon_sprite:
			current_weapon_sprite.rotation = weapon_marker.rotation

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		perform_attack()

func _update_animation(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
		anim.stop()
		return

	# Direções básicas (troque os nomes das animações conforme as suas)
	if abs(dir.x) > abs(dir.y):
		anim.play("run_right" if dir.x > 0.0 else "run_left")
	else:
		anim.play("run_down" if dir.y > 0.0 else "run_up")	

# ========== Armas ==========

func receive_weapon_data(weapon_data: Weapon_Data) -> void:
	print("Arma recebida: ", weapon_data.item_name)
	current_weapon_data = weapon_data
	call_deferred("setup_weapon")

func setup_weapon() -> void:
	if not current_weapon_data:
		return
	clear_current_weapon()
	_create_weapon_sprite()
	_setup_attack_area()
	_setup_projectile_spawn()

func clear_current_weapon() -> void:
	if current_weapon_sprite:
		current_weapon_sprite.queue_free()
		current_weapon_sprite = null

func _create_weapon_sprite() -> void:
	if not weapon_marker or not current_weapon_data:
		return
	current_weapon_sprite = AnimatedSprite2D.new()
	current_weapon_sprite.sprite_frames = current_weapon_data.sprite_frames
	# Se tiver nome de animação definido:
	if current_weapon_data.animation_name != "":
		current_weapon_sprite.animation = current_weapon_data.animation_name
	current_weapon_sprite.play()
	weapon_marker.add_child(current_weapon_sprite)

func _setup_attack_area() -> void:
	if not attack_area or not attack_collision or not current_weapon_data:
		return
	# Define a shape e offset para ataque melee
	attack_collision.shape = current_weapon_data.attack_collision
	attack_area.position = current_weapon_data.attack_collision_position
	attack_area.monitoring = false  # só liga durante o golpe

func _setup_projectile_spawn() -> void:
	if projectile_spawn_marker and current_weapon_data:
		projectile_spawn_marker.position = current_weapon_data.projectile_spawn_offset

# ========== Ataque ==========

func perform_attack() -> void:
	if not can_attack or not current_weapon_data:
		return
	can_attack = false

	match current_weapon_data.weapon_type:
		"melee":
			_melee_attack()
		"projectile":
			_projectile_attack()
		_:
			# fallback: melee
			_melee_attack()

	# cooldown baseado na velocidade da arma
	var cd: float = max(0.05, 1.0 / float(current_weapon_data.attack_speed))
	attack_cooldown.start(cd)
	await attack_cooldown.timeout
	can_attack = true

func _melee_attack() -> void:
	if not attack_area:
		return
	attack_area.monitoring = true
	# pequena janela ativa do hit
	await get_tree().create_timer(0.18).timeout
	attack_area.monitoring = false

func _projectile_attack() -> void:
	var scene := preload("res://projectile.tscn")
	if not scene or not projectile_spawn_marker:
		return
	var projectile: Area2D = scene.instantiate()
	projectile.global_position = projectile_spawn_marker.global_position
	var dir := (get_global_mouse_position() - projectile_spawn_marker.global_position).normalized()

	# Espera que o Projectile.gd tenha o método abaixo
	if projectile.has_method("setup_from_weapon_data"):
		projectile.setup_from_weapon_data(current_weapon_data, dir)
	get_tree().current_scene.add_child(projectile)

func _on_attack_hit(body: Node) -> void:
	if body.is_in_group("enemies"):
		_apply_damage_to_target(body)

func _apply_damage_to_target(target: Node) -> void:
	if target.has_method("take_damage") and current_weapon_data:
		target.take_damage(current_weapon_data.damage)
