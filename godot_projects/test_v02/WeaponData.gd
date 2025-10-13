class_name Weapon_Data 
extends Node

@export var sprite_frames: SpriteFrames
@export var animation_name: String = "default"
@export var collision_shape: Shape2D  # Para coleta do item
@export var item_name: String
@export var value: int

# === DADOS DA ARMA ===
@export var attack_collision: Shape2D  # Collision do ataque
@export var attack_collision_position: Vector2 = Vector2.ZERO
@export var projectile_spawn_offset: Vector2 = Vector2.ZERO
@export var weapon_type: String = "melee"  # "melee", "projectile"
@export var damage: float = 10
@export var attack_speed: float = 1.0
@export var range: float = 100.0
