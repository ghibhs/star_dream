class_name WeaponData
extends Resource

@export var sprite_frames: SpriteFrames
@export var animation_name: String = "default"
@export var collision_shape: Shape2D  # Para coleta do item
@export var item_name: String
@export var icon: Texture2D  # Ícone para inventário/hotbar
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
@export var attack_cooldown: float = 0.5  # Tempo de cooldown entre ataques em segundos
@export var weapon_range: float = 100.0

# === HITBOX DE ATAQUE (Golpe) ===
@export_group("Attack Hitbox")
@export var attack_hitbox_shape: Shape2D  # Forma do golpe (RectangleShape2D para espadas)
@export var attack_hitbox_offset: Vector2 = Vector2(30, 0)  # Distância à frente do player
@export var attack_hitbox_duration: float = 0.1  # Duração do golpe em segundos
@export var attack_hitbox_color: Color = Color(0, 1, 0, 0.95)  # Cor de debug (verde padrão)

# === DADOS DO PROJÉTIL (se weapon_type = "projectile") ===
@export var projectile_speed: float = 300.0
@export var projectile_sprite_frames: SpriteFrames  # Sprite do projétil
@export var projectile_name: String = "default"
@export var projectile_collision: Shape2D  # Collision do projétil
@export var pierce: bool = false
@export var projectile_scale: Vector2 = Vector2.ONE

# === SISTEMA DE CARREGAMENTO (para arcos) ===
@export_group("Charge System")
@export var can_charge: bool = false  # Se a arma pode ser carregada
@export var min_charge_time: float = 0.2  # Tempo mínimo para carregar
@export var max_charge_time: float = 2.0  # Tempo máximo de carregamento
@export var min_damage_multiplier: float = 0.5  # Multiplicador mínimo (50% do dano)
@export var max_damage_multiplier: float = 3.0  # Multiplicador máximo (300% do dano)
@export var charge_speed_multiplier: float = 1.5  # Multiplicador de velocidade quando carregado
@export var charge_color: Color = Color(1, 0.8, 0, 0.8)  # Cor do indicador de carga (amarelo)
