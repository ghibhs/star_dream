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
var beam_sprite_container: Node2D  # Container para sprites repetidos
var beam_sprites: Array = []  # Array de sprites ao longo do raio
var beam_line: Line2D
var impact_particles: CPUParticles2D
var sprite_segment_size: float = 32.0  # Tamanho de cada segmento de sprite

# Sistema
var raycast: RayCast2D
var hit_area: Area2D
var collision_shape: CollisionShape2D
var enemies_in_beam: Array = []
var damage_timer: float = 0.0
var duration_timer: float = 0.0

# Sistema de parada ao atingir inimigo
var beam_stopped_at_enemy: bool = false
var enemy_hit_position: Vector2 = Vector2.ZERO
var impact_area_on_enemy: Node2D = null  # Área de impacto persistente


func _ready() -> void:
	# Cria raycast para detectar obstáculos
	raycast = RayCast2D.new()
	add_child(raycast)
	raycast.enabled = true
	raycast.collision_mask = 1  # Paredes
	raycast.target_position = Vector2(max_range, 0)
	
	# Container para sprites repetidos
	beam_sprite_container = Node2D.new()
	add_child(beam_sprite_container)
	
	# Array de sprites (será preenchido dinamicamente)
	beam_sprites = []
	
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
	hit_area.collision_mask = 4  # Inimigos (layer 3, bit 4)
	hit_area.body_entered.connect(_on_enemy_entered)
	hit_area.body_exited.connect(_on_enemy_exited)
	
	collision_shape = CollisionShape2D.new()
	hit_area.add_child(collision_shape)
	var rect = RectangleShape2D.new()
	rect.size = Vector2(max_range, beam_width)
	collision_shape.shape = rect
	collision_shape.position = Vector2(max_range / 2, 0)
	
	print("[BEAM] ⚡ Raio contínuo criado")
	print("[BEAM]    Collision mask: %d (detecta layer 3 - inimigos)" % hit_area.collision_mask)


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
		
		# Configura sprite - cria sprites repetidos
		if spell.sprite_frames:
			# Detecta tamanho do sprite automaticamente
			var test_texture = spell.sprite_frames.get_frame_texture(spell.animation_name if spell.animation_name != "" else "default", 0)
			if test_texture:
				sprite_segment_size = test_texture.get_width()
				print("[BEAM] 🎨 Tamanho do sprite detectado: %.0fpx" % sprite_segment_size)
			
			# Calcula quantos sprites precisamos
			var segments_needed = ceil(max_range / sprite_segment_size) + 1
			print("[BEAM] 🎨 Criando %d segmentos de sprite" % segments_needed)
			
			# Cria sprites ao longo do raio
			for i in range(segments_needed):
				var sprite = AnimatedSprite2D.new()
				beam_sprite_container.add_child(sprite)
				sprite.sprite_frames = spell.sprite_frames
				
				# Centraliza o sprite vertical e horizontalmente
				sprite.centered = true
				# Posiciona ao longo do raio (X), centralizado automaticamente (Y)
				sprite.position = Vector2(i * sprite_segment_size + sprite_segment_size / 2.0, 0)
				
				if spell.animation_name != "":
					sprite.play(spell.animation_name)
				else:
					sprite.play()
				
				# Offset aleatório para variação visual
				sprite.frame = i % sprite.sprite_frames.get_frame_count(sprite.animation)
				beam_sprites.append(sprite)
			
			print("[BEAM] 🎨 Usando %d sprites repetidos" % beam_sprites.size())
		else:
			beam_line.visible = true
			if "spell_color" in spell:
				beam_line.default_color = spell.spell_color
			print("[BEAM] 🎨 Usando Line2D (fallback)")
		
		# Atualiza raycast
		raycast.target_position = Vector2(max_range, 0)
	
	activate()
	print("[BEAM] ⚡ Raio configurado - DPS: %.1f, Custo: %.1f mana/s" % [damage_per_second, mana_per_second])


func activate() -> void:
	"""Ativa o raio"""
	is_active = true
	impact_particles.emitting = true
	print("[BEAM] 🔥 Raio ATIVADO!")
	print("[BEAM]    DPS: %.1f" % damage_per_second)
	print("[BEAM]    Largura: %.1f" % beam_width)
	print("[BEAM]    Alcance: %.1f" % max_range)


func deactivate() -> void:
	"""Desativa o raio"""
	is_active = false
	
	# Esconde todos os sprites
	for sprite in beam_sprites:
		if is_instance_valid(sprite):
			sprite.visible = false
	
	beam_line.visible = false
	impact_particles.emitting = false
	
	# Remove efeitos dos inimigos
	for enemy in enemies_in_beam:
		if is_instance_valid(enemy) and spell_data.apply_status_effect:
			remove_status_effect(enemy)
	
	enemies_in_beam.clear()
	
	# Remove área de impacto persistente
	if impact_area_on_enemy and is_instance_valid(impact_area_on_enemy):
		impact_area_on_enemy.queue_free()
		impact_area_on_enemy = null
		print("[BEAM]    🗑️ Área de impacto removida")
	
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
	
	# Se parou no inimigo, limita o raio até lá
	if beam_stopped_at_enemy:
		var local_hit_pos = to_local(enemy_hit_position)
		end_point = local_hit_pos
	elif raycast.is_colliding():
		end_point = raycast.get_collision_point() - global_position
	else:
		end_point = Vector2(max_range, 0)
	
	var beam_length = end_point.length()
	
	# Atualiza visual dos sprites - mostra apenas os necessários
	if beam_sprites.size() > 0:
		var segments_visible = ceil(beam_length / sprite_segment_size)
		
		for i in range(beam_sprites.size()):
			var sprite = beam_sprites[i]
			if i < segments_visible:
				sprite.visible = true
				
				# Último sprite pode precisar ser cortado
				if i == segments_visible - 1:
					var remaining = beam_length - (i * sprite_segment_size)
					var scale_x = remaining / sprite_segment_size
					sprite.scale.x = clamp(scale_x, 0.1, 1.0)
				else:
					sprite.scale.x = 1.0
			else:
				sprite.visible = false
	
	# Atualiza Line2D
	if beam_line.visible:
		beam_line.set_point_position(1, end_point)
	
	# Atualiza partículas
	impact_particles.position = end_point
	
	# Atualiza collision shape
	if collision_shape and collision_shape.shape:
		collision_shape.shape.size = Vector2(beam_length, beam_width)
		collision_shape.position = Vector2(beam_length / 2, 0)
	
	# Atualiza posição da área de impacto para seguir o inimigo
	if beam_stopped_at_enemy and impact_area_on_enemy and is_instance_valid(impact_area_on_enemy):
		# Verifica se ainda há inimigos no raio
		if enemies_in_beam.size() > 0 and is_instance_valid(enemies_in_beam[0]):
			var target_enemy = enemies_in_beam[0]
			impact_area_on_enemy.global_position = target_enemy.global_position
			enemy_hit_position = target_enemy.global_position
		else:
			# Sem inimigos válidos, remove a área e libera o raio
			impact_area_on_enemy.queue_free()
			impact_area_on_enemy = null
			beam_stopped_at_enemy = false
			print("[BEAM]    🗑️ Área removida (sem alvos válidos)")
			print("[BEAM]    🔄 Raio liberado")
	
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
	
	if enemies_in_beam.size() > 0:
		print("[BEAM] 💥 Aplicando dano a %d inimigos (%.1f dano cada)" % [enemies_in_beam.size(), damage_tick])
	
	for enemy in enemies_in_beam:
		if not is_instance_valid(enemy):
			continue
		
		if enemy.has_method("take_damage"):
			enemy.take_damage(damage_tick, false)
			print("[BEAM]    ⚔️ Dano aplicado a %s" % enemy.name)
		
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
		
		# Se o raio deve parar ao atingir inimigo (apenas o primeiro)
		if spell_data and spell_data.beam_stops_at_enemy and not beam_stopped_at_enemy:
			beam_stopped_at_enemy = true
			enemy_hit_position = body.global_position
			print("[BEAM] 🛑 Raio parou no inimigo: %s" % body.name)
			
			# Cria área de impacto no inimigo (persiste enquanto raio ativo)
			if spell_data.create_impact_area:
				create_impact_on_enemy(body)


func _on_enemy_exited(body: Node2D) -> void:
	"""Inimigo saiu do raio"""
	if enemies_in_beam.has(body):
		enemies_in_beam.erase(body)
		
		if spell_data.apply_status_effect:
			remove_status_effect(body)
		
		# Se era o inimigo que parou o raio, remove a área e reseta o estado
		if beam_stopped_at_enemy and enemies_in_beam.size() == 0:
			if impact_area_on_enemy and is_instance_valid(impact_area_on_enemy):
				impact_area_on_enemy.queue_free()
				impact_area_on_enemy = null
				print("[BEAM]    🗑️ Área de impacto removida (inimigo saiu)")
			beam_stopped_at_enemy = false
			print("[BEAM]    🔄 Raio liberado (sem alvos)")
		
		print("[BEAM] 🚪 Inimigo saiu: %s" % body.name)


func create_impact_on_enemy(enemy: Node2D) -> void:
	"""Cria área de impacto quando raio atinge inimigo"""
	if not spell_data or not spell_data.create_impact_area:
		return
	
	# Se já existe uma área, não cria outra
	if impact_area_on_enemy and is_instance_valid(impact_area_on_enemy):
		return
	
	# Carrega o script da área de impacto
	var impact_area_script = preload("res://scripts/spells/spell_impact_area.gd")
	var impact_area = Area2D.new()
	impact_area.set_script(impact_area_script)
	
	# Posiciona no inimigo
	impact_area.global_position = enemy.global_position
	
	# Adiciona ao mundo
	if get_parent():
		get_parent().add_child(impact_area)
	
	# Configura a área com duração LONGA (vai ser destruída quando o beam desativar)
	if impact_area.has_method("setup"):
		impact_area.setup(
			spell_data.impact_area_damage,
			spell_data.impact_area_radius,
			999.0,  # Duração muito longa - vai ser removida manualmente
			spell_data.impact_area_sprite_frames,
			spell_data.impact_area_animation
		)
	
	# Salva referência
	impact_area_on_enemy = impact_area
	
	print("[BEAM]    💥 Área de impacto criada no inimigo: %s" % enemy.name)
