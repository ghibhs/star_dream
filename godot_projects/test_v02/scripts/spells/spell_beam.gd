# spell_beam.gd
extends Node2D
class_name SpellBeam

## Raio contínuo que segue o mouse
## Usado para: Raio de gelo, Laser, Raio elétrico, etc.

var spell_data: SpellData
var owner_player: Node2D
var is_active: bool = false

# Propriedades do raio
var damage_per_second: float = 25.0
var mana_per_second: float = 10.0
var max_range: float = 500.0
var beam_width: float = 20.0
var beam_duration: float = 3.0

# Visuais
var beam_sprite: AnimatedSprite2D
var beam_line: Line2D
var impact_particles: CPUParticles2D

# Sistema
var raycast: RayCast2D
var hit_area: Area2D
var collision_shape: CollisionShape2D
var enemies_in_beam: Array = []
var damage_timer: float = 0.0
var duration_timer: float = 0.0


func _ready() -> void:
	# Cria raycast para detectar obstáculos
	raycast = RayCast2D.new()
	add_child(raycast)
	raycast.enabled = true
	raycast.collision_mask = 1  # Paredes
	raycast.target_position = Vector2(max_range, 0)
	
	# Sprite animado
	beam_sprite = AnimatedSprite2D.new()
	add_child(beam_sprite)
	beam_sprite.visible = false
	beam_sprite.centered = false
	beam_sprite.offset = Vector2(0, -beam_width / 2)
	
	# Fallback Line2D
	beam_line = Line2D.new()
	add_child(beam_line)
	beam_line.width = beam_width
	beam_line.default_color = Color(0.3, 0.7, 1.0, 0.8)
	beam_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	beam_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	beam_line.add_point(Vector2.ZERO)
	beam_line.add_point(Vector2(max_range, 0))
	beam_line.visible = false
	
	# Partículas de impacto
	impact_particles = CPUParticles2D.new()
	add_child(impact_particles)
	impact_particles.emitting = false
	impact_particles.amount = 20
	impact_particles.lifetime = 0.5
	impact_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	impact_particles.emission_sphere_radius = 10.0
	impact_particles.direction = Vector2(-1, 0)
	impact_particles.spread = 45.0
	impact_particles.initial_velocity_min = 50.0
	impact_particles.initial_velocity_max = 100.0
	impact_particles.color = Color(0.6, 0.9, 1.0)
	
	# Área de detecção de inimigos
	hit_area = Area2D.new()
	add_child(hit_area)
	hit_area.collision_layer = 0
	hit_area.collision_mask = 4  # Inimigos
	hit_area.body_entered.connect(_on_enemy_entered)
	hit_area.body_exited.connect(_on_enemy_exited)
	
	collision_shape = CollisionShape2D.new()
	hit_area.add_child(collision_shape)
	var rect = RectangleShape2D.new()
	rect.size = Vector2(max_range, beam_width)
	collision_shape.shape = rect
	collision_shape.position = Vector2(max_range / 2, 0)
	
	print("[BEAM] ⚡ Raio contínuo criado")


func setup(spell: SpellData, player: Node2D) -> void:
	"""Configura o raio"""
	spell_data = spell
	owner_player = player
	
	if spell:
		damage_per_second = spell.damage_per_second
		mana_per_second = spell.mana_per_second
		max_range = spell.spell_range
		beam_width = spell.beam_width
		beam_duration = spell.beam_duration
		
		# Configura sprite
		if spell.sprite_frames:
			beam_sprite.sprite_frames = spell.sprite_frames
			if spell.animation_name != "":
				beam_sprite.play(spell.animation_name)
			else:
				beam_sprite.play()
			beam_sprite.visible = true
			print("[BEAM] 🎨 Usando sprite animado")
		else:
			beam_line.visible = true
			if "spell_color" in spell:
				beam_line.default_color = spell.spell_color
			print("[BEAM] 🎨 Usando Line2D")
		
		# Atualiza raycast
		raycast.target_position = Vector2(max_range, 0)
	
	activate()
	print("[BEAM] ⚡ Raio configurado - DPS: %.1f, Custo: %.1f mana/s" % [damage_per_second, mana_per_second])


func activate() -> void:
	"""Ativa o raio"""
	is_active = true
	impact_particles.emitting = true
	print("[BEAM] 🔥 Raio ATIVADO!")


func deactivate() -> void:
	"""Desativa o raio"""
	is_active = false
	beam_sprite.visible = false
	beam_line.visible = false
	impact_particles.emitting = false
	
	# Remove efeitos dos inimigos
	for enemy in enemies_in_beam:
		if is_instance_valid(enemy) and spell_data.apply_status_effect:
			remove_status_effect(enemy)
	
	enemies_in_beam.clear()
	print("[BEAM] 🛑 Raio DESATIVADO!")
	queue_free()


func _process(delta: float) -> void:
	if not is_active:
		return
	
	# Timer de duração
	duration_timer += delta
	if duration_timer >= beam_duration:
		print("[BEAM] ⏱️ Duração máxima atingida")
		deactivate()
		return
	
	# Segue o player
	if owner_player:
		global_position = owner_player.global_position
		
		# Rotaciona para o mouse
		var mouse_pos = owner_player.get_global_mouse_position()
		var direction = (mouse_pos - global_position).normalized()
		global_rotation = direction.angle()
	
	# Atualiza raycast
	raycast.force_raycast_update()
	
	# Calcula ponto final
	var end_point: Vector2
	if raycast.is_colliding():
		end_point = raycast.get_collision_point() - global_position
	else:
		end_point = Vector2(max_range, 0)
	
	var beam_length = end_point.length()
	
	# Atualiza visual do sprite
	if beam_sprite.visible and beam_sprite.sprite_frames:
		var texture = beam_sprite.sprite_frames.get_frame_texture(beam_sprite.animation, beam_sprite.frame)
		if texture:
			beam_sprite.scale.x = beam_length / texture.get_width()
			beam_sprite.scale.y = 1.0
	
	# Atualiza Line2D
	if beam_line.visible:
		beam_line.set_point_position(1, end_point)
	
	# Atualiza partículas
	impact_particles.position = end_point
	
	# Atualiza collision shape
	if collision_shape and collision_shape.shape:
		collision_shape.shape.size = Vector2(beam_length, beam_width)
		collision_shape.position = Vector2(beam_length / 2, 0)
	
	# Aplica dano
	damage_timer += delta
	if damage_timer >= 0.1:  # Dano a cada 0.1s
		apply_damage()
		damage_timer = 0.0
	
	# Consome mana
	if owner_player and owner_player.has_method("consume_mana_continuous"):
		var mana_consumed = owner_player.consume_mana_continuous(mana_per_second * delta)
		if not mana_consumed:
			print("[BEAM] ⚠️ Mana insuficiente!")
			deactivate()


func apply_damage() -> void:
	"""Aplica dano aos inimigos no raio"""
	var damage_tick = damage_per_second * 0.1
	
	for enemy in enemies_in_beam:
		if not is_instance_valid(enemy):
			continue
		
		if enemy.has_method("take_damage"):
			enemy.take_damage(damage_tick, false)
		
		# Aplica/renova status effect
		if spell_data and spell_data.apply_status_effect:
			apply_status_effect(enemy)


func apply_status_effect(enemy: Node2D) -> void:
	"""Aplica efeito de status"""
	if not spell_data:
		return
	
	match spell_data.status_effect_type:
		"slow":
			if enemy.has_method("apply_slow"):
				enemy.apply_slow(spell_data.status_effect_power, 0.5)  # Renova a cada 0.5s
		"stun":
			if enemy.has_method("apply_stun"):
				enemy.apply_stun(0.5)


func remove_status_effect(enemy: Node2D) -> void:
	"""Remove efeito de status"""
	if not spell_data:
		return
	
	match spell_data.status_effect_type:
		"slow":
			if enemy.has_method("remove_slow"):
				enemy.remove_slow()


func _on_enemy_entered(body: Node2D) -> void:
	"""Inimigo entrou no raio"""
	if body.is_in_group("enemies") and not enemies_in_beam.has(body):
		enemies_in_beam.append(body)
		print("[BEAM] 🎯 Inimigo entrou: %s" % body.name)


func _on_enemy_exited(body: Node2D) -> void:
	"""Inimigo saiu do raio"""
	if enemies_in_beam.has(body):
		enemies_in_beam.erase(body)
		
		if spell_data.apply_status_effect:
			remove_status_effect(body)
		
		print("[BEAM] 🚪 Inimigo saiu: %s" % body.name)
