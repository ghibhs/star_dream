# ItemData.gd
class_name ItemData
extends Resource

# Dados visuais do item coletável
@export var sprite_frames: SpriteFrames
@export var animation_name: String = "default"
@export var collision_shape: Shape2D  # Para coleta do item
@export var item_name: String
@export var value: int

# === DADOS DA ARMA ===
@export var attack_collision: Shape2D  # Collision do ataque
@export var projectile_spawn_offset: Vector2 = Vector2.ZERO
@export var weapon_type: String = "melee"  # "melee", "projectile"
@export var damage: int = 10
@export var attack_speed: float = 1.0
@export var range: float = 100.0

# === DADOS DO PROJÉTIL (se weapon_type = "projectile") ===
@export var projectile_speed: float = 300.0
@export var projectile_sprite_frames: SpriteFrames  # Sprite do projétil
@export var projectile_animation: String = "default"
@export var projectile_collision: Shape2D  # Collision do projétil
@export var pierce: bool = false

# Efeitos
@export var sound_effect: AudioStream
@export var hit_effect: PackedScene
