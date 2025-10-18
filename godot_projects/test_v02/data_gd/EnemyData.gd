class_name Enemy_Data
extends Resource

# === INFORMAÇÕES BÁSICAS ===
@export var enemy_name: String = "Enemy"
@export var sprite_frames: SpriteFrames
@export var animation_name: String = "walk"
@export var sprite_scale: Vector2 = Vector2.ONE

# === STATS DE COMBATE ===
@export var max_health: float = 50.0
@export var damage: float = 10.0
@export var defense: float = 0.0

# === MOVIMENTO ===
@export var move_speed: float = 80.0
@export var chase_range: float = 200.0  # Distância para começar a perseguir
@export var attack_range: float = 30.0  # Distância para atacar

# === COLISÃO ===
@export var collision_shape: Shape2D  # Forma da colisão do corpo
@export var hitbox_shape: Shape2D     # Forma da hitbox de dano ao player

# === COMPORTAMENTO ===
@export_enum("Passive", "Aggressive", "Patrol") var behavior: String = "Aggressive"
@export var attack_cooldown: float = 1.5  # Tempo entre ataques

# === REWARDS ===
@export var experience_drop: int = 10
@export var coin_drop: int = 5

# === VISUAL ===
@export var death_animation: String = "death"
@export var hit_flash_duration: float = 0.1
