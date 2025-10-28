# ice_beam.gd
extends Node2D

## Raio laser contínuo de gelo (Ice Bolt)

@export var damage_per_second: float = 25.0  # Dano por segundo
@export var max_range: float = 500.0  # Alcance máximo do raio
@export var beam_width: float = 20.0  # Largura do raio
@export var mana_cost_per_second: float = 10.0  # Custo de mana por segundo
@export var slow_amount: float = 0.5  # Reduz velocidade em 50%

var is_active: bool = false
var direction: Vector2 = Vector2.RIGHT
var owner_player: Node2D = null
var spell_data: Resource = null

# Visual do raio
var beam_sprite: AnimatedSprite2D  # Sprite animado do raio
var beam_line: Line2D  # Fallback se não houver sprite
var beam_particles: CPUParticles2D
var hit_area: Area2D
var collision_shape: CollisionShape2D

# Raycasting para detectar colisão com paredes/obstáculos
var raycast: RayCast2D

# Inimigos sendo atingidos pelo raio
var enemies_in_beam: Array = []
var damage_timer: float = 0.0
var damage_interval: float = 0.1  # Aplica dano a cada 0.1s

func _ready() -> void:
	# Cria o raycast para detectar obstáculos
	raycast = RayCast2D.new()
	add_child(raycast)
	raycast.enabled = true
	raycast.collision_mask = 1  # Layer de paredes/obstáculos
	raycast.target_position = Vector2(max_range, 0)
	
	# Cria sprite animado do raio (novo sistema)
	beam_sprite = AnimatedSprite2D.new()
	add_child(beam_sprite)
	beam_sprite.visible = false
	beam_sprite.centered = false  # Origem no canto esquerdo
	beam_sprite.offset = Vector2(0, -beam_width / 2)  # Centraliza verticalmente
	
	# Cria a linha visual do raio (fallback se não houver SpriteFrames)
	beam_line = Line2D.new()
	add_child(beam_line)
	beam_line.width = beam_width
	beam_line.default_color = Color(0.2, 0.7, 1.0, 0.8)  # Azul gelo
	beam_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	beam_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	beam_line.add_point(Vector2.ZERO)
	beam_line.add_point(Vector2(max_range, 0))
	beam_line.visible = false
	
	# Cria partículas no final do raio
	beam_particles = CPUParticles2D.new()
	add_child(beam_particles)
	beam_particles.emitting = false
	beam_particles.amount = 20
	beam_particles.lifetime = 0.5
	beam_particles.one_shot = false
	beam_particles.speed_scale = 1.5
	beam_particles.explosiveness = 0.2
	beam_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	beam_particles.emission_sphere_radius = 10.0
	beam_particles.direction = Vector2(-1, 0)
	beam_particles.spread = 45.0
	beam_particles.gravity = Vector2.ZERO
	beam_particles.initial_velocity_min = 50.0
	beam_particles.initial_velocity_max = 100.0
	beam_particles.scale_amount_min = 2.0
	beam_particles.scale_amount_max = 4.0
	beam_particles.color = Color(0.6, 0.9, 1.0, 1.0)
	
	# Cria área de colisão para detectar inimigos
	hit_area = Area2D.new()
	add_child(hit_area)
	hit_area.collision_layer = 0
	hit_area.collision_mask = 4  # Layer de inimigos
	hit_area.body_entered.connect(_on_body_entered)
	hit_area.body_exited.connect(_on_body_exited)
	
	collision_shape = CollisionShape2D.new()
	hit_area.add_child(collision_shape)
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(max_range, beam_width)
	collision_shape.shape = rect_shape
	collision_shape.position = Vector2(max_range / 2, 0)
	
	print("[ICE BEAM] 🧊 Raio laser de gelo criado")


func setup(spell: Resource, player: Node2D) -> void:
	"""Configura o raio com os dados da magia"""
	owner_player = player
	spell_data = spell
	
	if spell:
		damage_per_second = spell.damage
		max_range = spell.spell_range
		mana_cost_per_second = spell.mana_cost
		slow_amount = spell.speed_modifier
		
		# Se o spell tem sprite_frames, usa sprite animado
		if "sprite_frames" in spell and spell.sprite_frames:
			beam_sprite.sprite_frames = spell.sprite_frames
			if "animation_name" in spell and spell.animation_name != "":
				beam_sprite.play(spell.animation_name)
			else:
				beam_sprite.play()
			print("[ICE BEAM] 🎨 Usando AnimatedSprite2D com animação")
		else:
			# Fallback: usa Line2D com cor do spell
			if "spell_color" in spell:
				beam_line.default_color = spell.spell_color
			print("[ICE BEAM] 🎨 Usando Line2D como fallback")
		
		# Configura cor das partículas
		if "spell_color" in spell and beam_particles:
			beam_particles.color = spell.spell_color
	
	# NÃO define posição ou rotação aqui
	# O raio será filho do weapon_marker, então usa posição/rotação relativa
	
	activate()


func activate() -> void:
	"""Ativa o raio laser"""
	is_active = true
	
	# Ativa sprite animado OU Line2D (dependendo do que está configurado)
	if beam_sprite.sprite_frames:
		beam_sprite.visible = true
		beam_sprite.play()
	else:
		beam_line.visible = true
	
	beam_particles.emitting = true
	print("[ICE BEAM] ⚡ Raio ativado!")


func deactivate() -> void:
	"""Desativa o raio laser"""
	is_active = false
	beam_sprite.visible = false
	beam_sprite.stop()
	beam_line.visible = false
	beam_particles.emitting = false
	
	# Remove slow dos inimigos
	for enemy in enemies_in_beam:
		if is_instance_valid(enemy) and enemy.has_method("remove_slow"):
			enemy.remove_slow()
	
	enemies_in_beam.clear()
	print("[ICE BEAM] 🛑 Raio desativado!")
	queue_free()


func _process(delta: float) -> void:
	if not is_active:
		return
	
	# Acompanha a posição do player
	if owner_player:
		global_position = owner_player.global_position
		
		# Rotaciona o raio para apontar para o mouse
		var mouse_pos = owner_player.get_global_mouse_position()
		var direction_to_mouse = (mouse_pos - global_position).normalized()
		global_rotation = direction_to_mouse.angle()
	
	# Direction é sempre para direita (depois da rotação)
	var beam_direction = Vector2.RIGHT
	
	# Atualiza o raycast para detectar obstáculos
	raycast.target_position = beam_direction * max_range
	raycast.force_raycast_update()
	
	# Calcula o ponto final do raio (parede ou alcance máximo)
	var end_point: Vector2
	if raycast.is_colliding():
		end_point = raycast.get_collision_point() - global_position
	else:
		end_point = beam_direction * max_range
	
	# Atualiza visual do raio
	var beam_length = end_point.length()
	
	# Se usando sprite animado, ajusta escala para esticar até o fim
	if beam_sprite.sprite_frames and beam_sprite.visible:
		# Escala X = comprimento do raio / largura original do sprite
		# Escala Y = largura desejada / altura original do sprite
		var sprite_texture = beam_sprite.sprite_frames.get_frame_texture(beam_sprite.animation, beam_sprite.frame)
		if sprite_texture:
			var original_width = sprite_texture.get_width()
			beam_sprite.scale.x = beam_length / original_width if original_width > 0 else 1.0
	
	# Se usando Line2D, atualiza ponto final
	if beam_line.visible:
		beam_line.set_point_position(1, end_point)
	
	# Atualiza partículas no fim do raio
	beam_particles.position = end_point
	
	# Atualiza collision shape (usa beam_length já calculado)
	if collision_shape and collision_shape.shape:
		collision_shape.shape.size = Vector2(beam_length, beam_width)
		collision_shape.position = Vector2(beam_length / 2, 0)
	
	# Aplica dano aos inimigos
	damage_timer += delta
	if damage_timer >= damage_interval:
		apply_damage_to_enemies()
		damage_timer = 0.0
	
	# Consome mana do player
	if owner_player and owner_player.has_method("consume_mana_continuous"):
		var mana_consumed = owner_player.consume_mana_continuous(mana_cost_per_second * delta)
		if not mana_consumed:
			print("[ICE BEAM] ⚠️ Mana insuficiente! Desativando raio...")
			deactivate()


func apply_damage_to_enemies() -> void:
	"""Aplica dano a todos os inimigos no raio"""
	var damage_this_tick = (damage_per_second * damage_interval)
	
	if enemies_in_beam.size() > 0:
		print("[ICE BEAM] ⚡ Aplicando dano a %d inimigos (dano: %.1f, slow: %.0f%%)" % [
			enemies_in_beam.size(),
			damage_this_tick,
			slow_amount * 100
		])
	
	for enemy in enemies_in_beam:
		if is_instance_valid(enemy) and enemy.has_method("take_damage"):
			# Aplica dano SEM stun (false) - Ice Beam só causa slow, não paralisa
			enemy.take_damage(damage_this_tick, false)
			
			# Aplica slow
			if enemy.has_method("apply_slow"):
				enemy.apply_slow(slow_amount, 0.5)  # Slow por 0.5s (renovado constantemente)


func _on_body_entered(body: Node2D) -> void:
	"""Quando um inimigo entra no raio"""
	if body.is_in_group("enemies") and not enemies_in_beam.has(body):
		enemies_in_beam.append(body)
		print("[ICE BEAM] 🎯 Inimigo entrou no raio: %s" % body.name)


func _on_body_exited(body: Node2D) -> void:
	"""Quando um inimigo sai do raio"""
	if enemies_in_beam.has(body):
		enemies_in_beam.erase(body)
		
		# Remove slow quando sair do raio
		if is_instance_valid(body) and body.has_method("remove_slow"):
			body.remove_slow()
		
		print("[ICE BEAM] 🚪 Inimigo saiu do raio: %s" % body.name)
