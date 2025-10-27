# magic_projectile.gd
extends Area2D
class_name MagicProjectile

## Projétil mágico configurável via SpellData

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
@onready var screen_notifier = $VisibleOnScreenNotifier2D

var spell_data: SpellData
var direction: Vector2
var speed: float
var damage: float
var pierce: bool = false
var homing: bool = false
var knockback_force: float = 0.0
var targets_hit: Array = []  # Para projéteis que atravessam
var lifetime: float = 5.0  # Tempo máximo de vida
var time_alive: float = 0.0

# Para homing
var nearest_enemy: Node2D = null
var homing_strength: float = 2.0


func _ready():
	body_entered.connect(_on_body_entered)
	if screen_notifier:
		screen_notifier.screen_exited.connect(_on_screen_exited)


func setup(spell: SpellData, dir: Vector2, caster_position: Vector2):
	"""Configura o projétil mágico baseado no SpellData"""
	spell_data = spell
	direction = dir.normalized()
	speed = spell.projectile_speed
	damage = spell.damage
	pierce = spell.pierce
	homing = spell.homing
	knockback_force = spell.knockback_force
	
	# Posiciona o projétil
	global_position = caster_position
	
	# Rotaciona para a direção
	rotation = direction.angle()
	
	# Configura visual se houver sprite_frames
	if spell.projectile_sprite_frames:
		animated_sprite.sprite_frames = spell.projectile_sprite_frames
		animated_sprite.play(spell.projectile_animation)
	else:
		# Visual padrão - círculo colorido
		animated_sprite.modulate = spell.spell_color
	
	animated_sprite.scale = spell.projectile_scale
	
	# Configura colisão se houver
	if spell.projectile_collision:
		collision.shape = spell.projectile_collision
	
	# TODO: Adicionar partículas de rastro se houver
	# if spell.trail_particle:
	#     add_trail_particles(spell.trail_particle)
	
	print("[MAGIC_PROJECTILE] ✨ Projétil configurado:")
	print("    Magia: %s" % spell.spell_name)
	print("    Dano: %.1f" % damage)
	print("    Velocidade: %.1f" % speed)
	print("    Pierce: %s | Homing: %s" % [pierce, homing])


func _physics_process(delta):
	time_alive += delta
	
	# Destrói se passou do tempo de vida
	if time_alive >= lifetime:
		queue_free()
		return
	
	# Homing - busca o inimigo mais próximo
	if homing:
		find_nearest_enemy()
		if nearest_enemy and is_instance_valid(nearest_enemy):
			var target_direction = (nearest_enemy.global_position - global_position).normalized()
			direction = direction.lerp(target_direction, homing_strength * delta)
			rotation = direction.angle()
	
	# Move o projétil
	position += direction * speed * delta


func find_nearest_enemy():
	"""Encontra o inimigo mais próximo"""
	var enemies = get_tree().get_nodes_in_group("enemies")
	var min_distance = INF
	nearest_enemy = null
	
	for enemy in enemies:
		if is_instance_valid(enemy):
			var distance = global_position.distance_to(enemy.global_position)
			if distance < min_distance and distance < spell_data.spell_range:
				min_distance = distance
				nearest_enemy = enemy


func _on_body_entered(body):
	"""Quando colide com algo"""
	# Evita atingir o mesmo alvo múltiplas vezes (se pierce)
	if pierce and targets_hit.has(body):
		return
	
	# Verifica se é inimigo
	if body.is_in_group("enemies"):
		# Aplica dano
		if body.has_method("take_damage"):
			body.take_damage(damage)
			print("[MAGIC_PROJECTILE] 💥 Causou %.1f de dano em %s" % [damage, body.name])
			
			# Adiciona knockback se houver
			if knockback_force > 0 and body.has_method("apply_knockback"):
				body.apply_knockback(direction, knockback_force)
			
			# Marca como atingido se pierce
			if pierce:
				targets_hit.append(body)
		
		# TODO: Spawn partículas de impacto
		# if spell_data.impact_particle:
		#     spawn_impact_effect(global_position)
		
		# TODO: Tocar som de impacto
		# if spell_data.impact_sound:
		#     play_impact_sound()
		
		# Destrói se não atravessa
		if not pierce:
			queue_free()
	
	# Colide com parede
	elif body.is_in_group("walls") or body is TileMapLayer:
		queue_free()


func _on_screen_exited():
	"""Quando sai da tela"""
	queue_free()
