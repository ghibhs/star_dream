extends CharacterBody2D

@export var speed: float = 100.0
@export var direction: Vector2 = Vector2.ZERO
@onready var animation = $AnimatedSprite2D

func _physics_process(_delta: float) -> void:
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if direction != Vector2.ZERO:
		play_animations(direction)
	else:
		animation.stop()
	
	if current_weapon_data:
		# Arma sempre aponta para o mouse
		weapon_marker.look_at(get_global_mouse_position())
		
	velocity = direction * speed
	move_and_slide()

func play_animations(dir: Vector2):
	
	if dir.x > 0 and dir.y == 0:
		animation.play("default")
	if dir.x < 0 and dir.y == 0:
		animation.play("new_animation_3")
	if dir.x == 0 and dir.y < 0:
		animation.play("new_animation_1")
	if dir.x == 0 and dir.y > 0:
		animation.play("new_animation_5")
	if dir.x > 0 and dir.y < 0:
		animation.play("new_animation")
	if dir.x < 0 and dir.y < 0:
		animation.play("new_animation_2")
	if dir.x < 0 and dir.y > 0:
		animation.play("new_animation_4")
	if dir.x > 0 and dir.y > 0:
		animation.play("new_animation_6")

var current_weapon_data: ItemData
@onready var weapon_marker = $WeaponMarker2D  # Onde fica a arma
@onready var projectile_spawn_marker = $WeaponMarker2D/ProjectileSpawnMarker2D

var current_weapon_sprite: AnimatedSprite2D
var attack_area: Area2D

func _ready():
	add_to_group("player")

func _process(delta):
	if current_weapon_data:
		# Arma sempre aponta para o mouse
		weapon_marker.look_at(get_global_mouse_position())

func _input(event):
	if event.is_action_pressed("attack"):
		perform_attack()

func receive_weapon_data(weapon_data: ItemData):
	print("Arma recebida: ", weapon_data.item_name)
	current_weapon_data = weapon_data
	call_deferred("setup_weapon")

func setup_weapon():
	if current_weapon_data:
		clear_current_weapon()
		create_weapon_sprite()
		setup_attack_area()
		setup_projectile_spawn()

func clear_current_weapon():
	if current_weapon_sprite:
		current_weapon_sprite.queue_free()
		current_weapon_sprite = null
	
	if attack_area:
		attack_area.queue_free()
		attack_area = null

func create_weapon_sprite():
	current_weapon_sprite = AnimatedSprite2D.new()
	current_weapon_sprite.sprite_frames = current_weapon_data.sprite_frames
	current_weapon_sprite.play(current_weapon_data.animation_name)
	weapon_marker.add_child(current_weapon_sprite)

func setup_attack_area():
	if current_weapon_data.attack_collision:
		attack_area = Area2D.new()
		var collision_shape = CollisionShape2D.new()
		collision_shape.shape = current_weapon_data.attack_collision
		
		attack_area.add_child(collision_shape)
		weapon_marker.add_child(attack_area)
		attack_area.body_entered.connect(_on_attack_hit)
		attack_area.monitoring = false  # Desabilitado por padrão

func setup_projectile_spawn():
	if projectile_spawn_marker and current_weapon_data:
		projectile_spawn_marker.position = current_weapon_data.projectile_spawn_offset

func perform_attack():
	if current_weapon_data:
		match current_weapon_data.weapon_type:
			"melee":
				melee_attack()
			"projectile":
				projectile_attack()

func melee_attack():
	print("Ataque corpo a corpo!")
	if attack_area:
		attack_area.monitoring = true
		await get_tree().create_timer(0.2).timeout
		attack_area.monitoring = false

func projectile_attack():
	print("Disparando projétil!")
	var projectile = preload("res://projectile.tscn").instantiate()
	
	projectile.global_position = projectile_spawn_marker.global_position
	var direction = (get_global_mouse_position() - projectile_spawn_marker.global_position).normalized()
	
	projectile.setup_from_weapon_data(current_weapon_data, direction)
	get_tree().current_scene.add_child(projectile)

func _on_attack_hit(body):
	if body.is_in_group("enemies"):
		apply_damage_to_target(body)

func apply_damage_to_target(target):
	if target.has_method("take_damage"):
		target.take_damage(current_weapon_data.damage)
		print("Dano aplicado: ", current_weapon_data.damage)
