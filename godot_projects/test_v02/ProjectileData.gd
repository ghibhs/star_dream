class_name ProjectileData
extends Node

@export var sprite_frames: SpriteFrames
@export var animation_name: String = "default"
@export var collision_shape: Shape2D  # Para coleta do item
@export var item_name: String
@export var value: int

# === DADOS DO PROJÉTIL (se weapon_type = "projectile") ===
@export var damage: float = 10
@export var projectile_speed: float = 300.0
@export var projectile_sprite_frames: SpriteFrames  # Sprite do projétil
@export var projectile_animation: String = "default"
@export var projectile_collision: Shape2D  # Collision do projétil
@export var pierce: bool = false
