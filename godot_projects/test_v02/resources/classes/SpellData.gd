# SpellData.gd
class_name SpellData
extends Resource

## Tipos de magia
enum SpellType {
	PROJECTILE,    # Bola de fogo, raio de gelo, etc
	AREA,          # Explosão, chuva de meteoros, etc
	BUFF,          # Aumenta status temporariamente
	DEBUFF,        # Enfraquece inimigos
	HEAL,          # Cura o jogador
	SUMMON,        # Invoca criaturas
	TELEPORT,      # Teleporte
	SHIELD         # Escudo mágico
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

@export_group("Projectile (if PROJECTILE type)")
@export var projectile_speed: float = 400.0
@export var projectile_sprite_frames: SpriteFrames
@export var projectile_animation: String = "default"
@export var projectile_collision: Shape2D
@export var projectile_scale: Vector2 = Vector2.ONE
@export var pierce: bool = false  # Atravessa inimigos
@export var homing: bool = false  # Persegue inimigos

@export_group("Beam/Ray (for continuous beam spells like Ice Beam)")
@export var sprite_frames: SpriteFrames  # Sprite animado do raio
@export var animation_name: String = "beam"  # Nome da animação no SpriteFrames

@export_group("Area Effect (if AREA type)")
@export var area_radius: float = 100.0
@export var area_duration: float = 2.0  # Duração da área
@export var damage_over_time: bool = false
@export var tick_interval: float = 0.5  # Intervalo entre danos

@export_group("Buff/Debuff (if BUFF/DEBUFF type)")
@export var duration: float = 5.0  # Duração do efeito
@export var speed_modifier: float = 1.0  # Multiplicador de velocidade
@export var damage_modifier: float = 1.0  # Multiplicador de dano
@export var defense_modifier: float = 1.0  # Multiplicador de defesa

@export_group("Heal (if HEAL type)")
@export var heal_amount: float = 50.0
@export var heal_over_time: bool = false
@export var heal_duration: float = 5.0

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
