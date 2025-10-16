# Projectile.gd
extends Area2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
@onready var screen_notifier = $VisibleOnScreenNotifier2D
@export var angle_offset_deg: float = 0.0

var direction: Vector2
var speed: float
var damage: float
var pierce: bool = false


func _ready():
	body_entered.connect(_on_body_entered)
	if screen_notifier:
		screen_notifier.screen_exited.connect(queue_free)

func setup_from_weapon_data(weapon_data: Weapon_Data, dir: Vector2):
	# Configura visual
	animated_sprite.sprite_frames = weapon_data.projectile_sprite_frames
	animated_sprite.play(weapon_data.projectile_name)
	animated_sprite.scale = weapon_data.projectile_scale
	
	# Configura collision
	collision.shape = weapon_data.projectile_collision
	
	# Configura movimento
	direction = dir.normalized()
	
	var ang : float = direction.angle() + deg_to_rad(angle_offset_deg)
	rotation = ang       # <- gira o Area2D (sprite + colisão juntos)
	
	speed = weapon_data.projectile_speed
	damage = weapon_data.damage
	pierce = weapon_data.pierce
	

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		
		if not pierce:
			queue_free()
	elif body.is_in_group("walls"):
		queue_free()
