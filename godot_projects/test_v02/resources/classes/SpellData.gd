# SpellData.gd
class_name SpellData
extends Resource

## Tipos de magia
enum SpellType {
	PROJECTILE,    # Projétil que viaja (bola de fogo, flecha mágica)
	BEAM,          # Raio contínuo (raio laser, raio de gelo)
	TARGETED       # Spawna no alvo (relâmpago, meteoro)
}

## Elemento da magia
enum Element {
	NONE,
	FIRE,          # Fogo
	ICE,           # Gelo
	LIGHTNING,     # Raio
	NATURE,        # Natureza
	DARK,          # Trevas
	LIGHT,         # Luz
	ARCANE         # Arcano
}

@export_group("Basic Info")
@export var spell_id: String = ""
@export var spell_name: String = "Magia"
@export var description: String = "Uma magia poderosa"
@export var icon: Texture2D  # Ícone para UI

@export_group("Spell Properties")
@export var spell_type: SpellType = SpellType.PROJECTILE
@export var element: Element = Element.FIRE
@export var mana_cost: float = 10.0
@export var cast_time: float = 0.5  # Tempo de conjuração em segundos
@export var cooldown: float = 1.0  # Tempo de recarga
@export var damage: float = 20.0
@export var spell_range: float = 300.0  # Alcance da magia

@export_group("Projectile Properties")
@export var projectile_speed: float = 400.0
@export var pierce: bool = false  # Atravessa inimigos
@export var homing: bool = false  # Persegue inimigos

@export_group("Beam Properties")
@export var beam_width: float = 20.0
@export var beam_duration: float = 3.0  # Duração máxima do raio
@export var damage_per_second: float = 25.0  # Dano por segundo
@export var mana_per_second: float = 10.0  # Custo de mana por segundo

@export_group("Targeted Properties")
@export var spawn_delay: float = 0.5  # Delay antes de spawnar no alvo
@export var warning_duration: float = 0.3  # Duração do aviso visual

@export_group("Visual Settings")
@export var sprite_frames: SpriteFrames  # Sprite animado da magia
@export var animation_name: String = "default"
@export var projectile_scale: Vector2 = Vector2.ONE

@export_group("Status Effects")
@export var apply_status_effect: bool = false
@export var status_effect_type: String = "slow"  # slow, stun, burn, freeze
@export var status_effect_duration: float = 2.0
@export var status_effect_power: float = 0.5  # 0.5 = 50% slow, etc

@export_group("Visual Effects")
@export var cast_particle: PackedScene  # Partículas ao conjurar
@export var impact_particle: PackedScene  # Partículas ao acertar
@export var trail_particle: PackedScene  # Rastro (para projéteis)
@export var spell_color: Color = Color.WHITE

@export_group("Audio")
@export var cast_sound: AudioStream
@export var impact_sound: AudioStream
@export var loop_sound: AudioStream  # Som contínuo (para áreas)

@export_group("Advanced")
@export var can_be_interrupted: bool = true  # Pode ser interrompido durante conjuração
@export var requires_target: bool = false  # Necessita de alvo
@export var max_targets: int = 1  # Número máximo de alvos
@export var knockback_force: float = 0.0  # Força de repulsão
