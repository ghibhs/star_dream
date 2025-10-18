class_name Weapon_Data
extends Resource

@export var sprite_frames: SpriteFrames
@export var animation_name: String = "default"
@export var collision_shape: Shape2D  # Para coleta do item
@export var item_name: String
@export var value: int
@export var Sprite_scale: Vector2 = Vector2.ONE

# ===== NOVOS CAMPOS =====
@export var melee_anim_name: String = "attack"    # animação do golpe melee no AnimatedSprite2D
@export var sprite_flip_on_left: bool = true      # inverte quando direção tiver x < 0
@export var sprite_tilt_deg: float = 10.0         # inclina um pouco (clockwise) quando mirar pra esquerda
@export var melee_swing_time: float = 0.20        # duração do golpe (segundos)

# Offsets da hitbox (relativos ao WeaponMarker2D) por direção principal/diagonal
@export var hitbox_offsets := {
	"down":       { "start": Vector2(10,  6), "end": Vector2(16,  12) },
	"up":         { "start": Vector2(10, -6), "end": Vector2(16, -12) },
	"left":       { "start": Vector2(-10, 0), "end": Vector2(-16, 0) },
	"right":      { "start": Vector2(10,  0), "end": Vector2(18,  0) },
	"up_right":   { "start": Vector2(8, -6),  "end": Vector2(16, -14) },
	"up_left":    { "start": Vector2(-8,-6),  "end": Vector2(-16,-14) },
	"down_right": { "start": Vector2(8,  6),  "end": Vector2(16,  14) },
	"down_left":  { "start": Vector2(-8, 6),  "end": Vector2(-16, 14) },
}

# === DADOS DA ARMA ===
@export var attack_collision: Shape2D              # forma da hitbox do melee
@export var attack_collision_position: Vector2 = Vector2.ZERO
@export var projectile_spawn_offset: Vector2 = Vector2.ZERO
@export var sprite_position: Vector2 = Vector2.ZERO
@export var weapon_type: String = "melee"  # "melee", "projectile"
@export var damage: float = 10
@export var attack_speed: float = 1.0
@export var range: float = 100.0

# === DADOS DO PROJÉTIL (se weapon_type = "projectile") ===
@export var projectile_speed: float = 300.0
@export var projectile_sprite_frames: SpriteFrames  # Sprite do projétil
@export var projectile_animation_name: String = "default"
@export var projectile_collision: Shape2D  # Colisão do projétil
@export var pierce: bool = false
@export var projectile_scale: Vector2 = Vector2.ONE
