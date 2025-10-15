extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var life_timer: Timer = $LifeTimer

var direction: Vector2
var speed: float
var damage: float
var pierce: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if screen_notifier:
		screen_notifier.screen_exited.connect(queue_free)
	if life_timer:
		life_timer.one_shot = true
		life_timer.start(5.0) # TTL de 5s
		life_timer.timeout.connect(queue_free)

	# (Opcional) Defina camadas/máscaras aqui se não setar no editor:
	# set_collision_layer_value(4, true) # layer 4
	# set_collision_mask_value(2, true)  # colide com enemies (layer 2)
	# set_collision_mask_value(3, true)  # colide com walls (layer 3)

func setup_from_weapon_data(weapon_data: Weapon_Data, dir: Vector2) -> void:
	direction = dir.normalized()
	speed = weapon_data.projectile_speed
	damage = weapon_data.damage
	pierce = weapon_data.pierce

	if animated_sprite:
		animated_sprite.sprite_frames = weapon_data.projectile_sprite_frames
		animated_sprite.animation = weapon_data.projectile_animation
		animated_sprite.play()
	if collision and weapon_data.projectile_collision:
		collision.shape = weapon_data.projectile_collision

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		if not pierce:
			queue_free()
	elif body.is_in_group("walls"):
		queue_free()
