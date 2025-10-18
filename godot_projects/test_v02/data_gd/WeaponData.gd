class_name Weapon_Data 
extends Resource

@export var sprite_frames: SpriteFrames
@export var animation_name: String = "default"
@export var collision_shape: Shape2D  # Para coleta do item
@export var item_name: String
@export var value: int
@export var Sprite_scale: Vector2 = Vector2.ONE


# === DADOS DA ARMA ===
@export var weapon_marker_position: Vector2 = Vector2.ZERO  # Posição do marker (pivot de rotação)
@export var attack_collision: Shape2D  # Collision do ataque
@export var attack_collision_position: Vector2 = Vector2.ZERO
@export var projectile_spawn_offset: Vector2 = Vector2.ZERO
@export var sprite_position: Vector2 = Vector2.ZERO
@export var weapon_type: String = "melee"  # "melee", "projectile"
@export var damage: float = 10
@export var attack_speed: float = 1.0
@export var weapon_range: float = 100.0

# === DADOS DO PROJÉTIL (se weapon_type = "projectile") ===
@export var projectile_speed: float = 300.0
@export var projectile_sprite_frames: SpriteFrames  # Sprite do projétil
@export var projectile_name: String = "default"
@export var projectile_collision: Shape2D  # Collision do projétil
@export var pierce: bool = false
@export var projectile_scale: Vector2 = Vector2.ONE
