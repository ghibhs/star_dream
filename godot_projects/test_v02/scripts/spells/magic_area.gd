# magic_area.gd
extends Area2D
class_name MagicArea

## Área de efeito mágico configurável via SpellData

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite_fallback: Sprite2D = $Sprite2D

var spell_data: SpellData
var damage: float
var damage_over_time: bool = false
var tick_interval: float = 0.5
var time_alive: float = 0.0
var time_since_last_tick: float = 0.0
var affected_bodies: Dictionary = {}  # body -> último tick de dano
var knockback_force: float = 0.0


func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func setup(spell: SpellData, spawn_position: Vector2):
	"""Configura a área mágica baseada no SpellData"""
	spell_data = spell
	damage = spell.damage
	damage_over_time = spell.damage_over_time
	tick_interval = spell.tick_interval
	knockback_force = spell.knockback_force
	
	global_position = spawn_position
	
	# Configura o raio da área
	var collision_shape = $CollisionShape2D
	if collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius = spell.area_radius
	
	# Configura visual - prioriza AnimatedSprite2D
	if "area_sprite_frames" in spell and spell.area_sprite_frames:
		animated_sprite.sprite_frames = spell.area_sprite_frames
		animated_sprite.visible = true
		sprite_fallback.visible = false
		
		# Toca animação
		if "area_animation" in spell and spell.area_animation != "":
			animated_sprite.play(spell.area_animation)
		else:
			animated_sprite.play()
		
		# Escala baseada no raio
		animated_sprite.scale = Vector2.ONE * (spell.area_radius / 50.0)
		
		print("[MAGIC_AREA] 🎨 Usando AnimatedSprite2D com animação")
	else:
		# Fallback para Sprite2D estático
		animated_sprite.visible = false
		sprite_fallback.visible = true
		sprite_fallback.modulate = spell.spell_color
		sprite_fallback.scale = Vector2.ONE * (spell.area_radius / 50.0)
		print("[MAGIC_AREA] 🎨 Usando Sprite2D como fallback")
	
	# TODO: Adicionar partículas
	# if spell.cast_particle:
	#     add_particles(spell.cast_particle)
	
	print("[MAGIC_AREA] 💥 Área mágica criada:")
	print("    Magia: %s" % spell.spell_name)
	print("    Raio: %.1f" % spell.area_radius)
	print("    Dano: %.1f" % damage)
	print("    DoT: %s | Intervalo: %.1fs" % [damage_over_time, tick_interval])
	print("    Duração: %.1fs" % spell.area_duration)
	
	# Destrói após a duração
	await get_tree().create_timer(spell.area_duration).timeout
	queue_free()


func _physics_process(delta):
	time_alive += delta
	time_since_last_tick += delta
	
	# Se for dano contínuo, aplica dano nos inimigos dentro da área
	if damage_over_time and time_since_last_tick >= tick_interval:
		apply_tick_damage()
		time_since_last_tick = 0.0


func apply_tick_damage():
	"""Aplica dano em todos os inimigos dentro da área"""
	for body in affected_bodies.keys():
		if is_instance_valid(body) and body.is_in_group("enemies"):
			if body.has_method("take_damage"):
				body.take_damage(damage)
				print("[MAGIC_AREA] 🔥 Tick de dano: %.1f em %s" % [damage, body.name])


func _on_body_entered(body):
	"""Quando um corpo entra na área"""
	if body.is_in_group("enemies"):
		affected_bodies[body] = time_alive
		
		# Se não for DoT, aplica dano instantâneo
		if not damage_over_time:
			if body.has_method("take_damage"):
				body.take_damage(damage)
				print("[MAGIC_AREA] 💥 Dano instantâneo: %.1f em %s" % [damage, body.name])
				
				# Aplica knockback
				if knockback_force > 0 and body.has_method("apply_knockback"):
					var direction = (body.global_position - global_position).normalized()
					body.apply_knockback(direction, knockback_force)


func _on_body_exited(body):
	"""Quando um corpo sai da área"""
	if affected_bodies.has(body):
		affected_bodies.erase(body)
