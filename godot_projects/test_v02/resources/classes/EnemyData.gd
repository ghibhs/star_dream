class_name EnemyData
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
@export var push_force: float = 50.0  # Força de empurrão (0 = não pode ser empurrado, >100 = empurrado facilmente)

# === COLISÃO ===
@export var collision_shape: Shape2D  # Forma da colisão do corpo
@export var hitbox_shape: Shape2D     # Forma da hitbox de dano ao player

# === HITBOX DE ATAQUE (Golpe) ===
@export_group("Attack Hitbox")
@export var attack_hitbox_shape: Shape2D  # Forma do golpe (RectangleShape2D recomendado)
@export var attack_hitbox_offset: Vector2 = Vector2(25, 0)  # Distância à frente do inimigo
@export var attack_hitbox_duration: float = 0.15  # Duração do golpe em segundos
@export var attack_hitbox_color: Color = Color(1, 0, 0, 0.9)  # Cor de debug (vermelho padrão)
@export var attack_warning_delay: float = 0.3  # Tempo de aviso antes do ataque (para dar tempo de esquiva)

# === KNOCKBACK (EMPURRÃO AO ATACAR) ===
@export_group("Knockback")
@export var applies_knockback: bool = true  # Se este inimigo causa empurrão ao atacar
@export var knockback_force: float = 300.0  # Força do empurrão (0 = sem empurrão, maior = empurrão mais forte)
@export var knockback_duration: float = 0.2  # Duração do empurrão em segundos

# === COMPORTAMENTO ===
@export_enum("Passive", "Aggressive", "Patrol") var behavior: String = "Aggressive"
@export var attack_cooldown: float = 1.5  # Tempo entre ataques

# === REWARDS ===
@export var experience_drop: int = 10
@export var coin_drop: int = 5

# === VISUAL ===
@export var death_animation: String = "death"
@export var hit_flash_duration: float = 0.1
