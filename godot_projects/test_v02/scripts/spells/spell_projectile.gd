# spell_projectile.gd
extends Area2D
class_name SpellProjectile

## Projétil mágico que viaja em linha reta
## Usado para: Bola de fogo, Seta mágica, Shard de gelo, etc.

var spell_data: SpellData
var direction: Vector2 = Vector2.RIGHT
var speed: float = 400.0
var damage: float = 20.0
var pierce: bool = false
var homing: bool = false
var owner_player: Node2D

var sprite: AnimatedSprite2D
var collision_shape: CollisionShape2D
var hit_enemies: Array = []  # Para controle de pierce
var target_enemy: Node2D = null  # Para homing


func _ready() -> void:
	# Cria sprite animado
	sprite = AnimatedSprite2D.new()
	add_child(sprite)
	
	# Cria colisão
	collision_shape = CollisionShape2D.new()
	add_child(collision_shape)
	var circle = CircleShape2D.new()
	circle.radius = 10.0
	collision_shape.shape = circle
	
	# Configuração da Area2D
	collision_layer = 0
	collision_mask = 4  # Layer de inimigos
	
	# Conecta sinal
	body_entered.connect(_on_body_entered)
	
	print("[PROJECTILE] 🎯 Projétil criado")


func setup(spell: SpellData, player: Node2D) -> void:
	"""Configura o projétil com dados do spell"""
	spell_data = spell
	owner_player = player
	
	if spell:
		speed = spell.projectile_speed
		damage = spell.damage
		pierce = spell.pierce
		homing = spell.homing
		
		# Configura sprite
		if spell.sprite_frames:
			sprite.sprite_frames = spell.sprite_frames
			sprite.scale = spell.projectile_scale
			
			if spell.animation_name != "":
				sprite.play(spell.animation_name)
			else:
				sprite.play()
			
			print("[PROJECTILE] 🎨 Animação configurada")
	
	# Direcão inicial para o mouse
	if player:
		var mouse_pos = player.get_global_mouse_position()
		direction = (mouse_pos - global_position).normalized()
		rotation = direction.angle()
	
	print("[PROJECTILE] ⚡ Projétil configurado - Dano: %.1f, Velocidade: %.1f" % [damage, speed])


func _process(delta: float) -> void:
	# Sistema de homing
	if homing and target_enemy and is_instance_valid(target_enemy):
		var target_direction = (target_enemy.global_position - global_position).normalized()
		direction = direction.lerp(target_direction, 5.0 * delta)  # Curva suave
		rotation = direction.angle()
	
	# Move o projétil
	global_position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	"""Quando atinge algo"""
	if not body.is_in_group("enemies"):
		return
	
	# Se já atingiu esse inimigo (modo pierce), ignora
	if pierce and hit_enemies.has(body):
		return
	
	print("[PROJECTILE] 💥 Atingiu: %s" % body.name)
	
	# Aplica dano
	if body.has_method("take_damage"):
		body.take_damage(damage, false)
	
	# Aplica status effect se tiver
	if spell_data and spell_data.apply_status_effect:
		apply_status_effect(body)
	
	# Registra hit para pierce
	if pierce:
		hit_enemies.append(body)
	else:
		# Destrói o projétil
		queue_free()


func apply_status_effect(enemy: Node2D) -> void:
	"""Aplica efeito de status no inimigo"""
	match spell_data.status_effect_type:
		"slow":
			if enemy.has_method("apply_slow"):
				enemy.apply_slow(spell_data.status_effect_power, spell_data.status_effect_duration)
				print("[PROJECTILE]    ❄️ Aplicou slow: %.0f%% por %.1fs" % [
					spell_data.status_effect_power * 100,
					spell_data.status_effect_duration
				])
		"stun":
			if enemy.has_method("apply_stun"):
				enemy.apply_stun(spell_data.status_effect_duration)
				print("[PROJECTILE]    ⚡ Aplicou stun por %.1fs" % spell_data.status_effect_duration)
		"burn":
			if enemy.has_method("apply_burn"):
				enemy.apply_burn(spell_data.status_effect_power, spell_data.status_effect_duration)
				print("[PROJECTILE]    🔥 Aplicou burn: %.1f dps por %.1fs" % [
					spell_data.status_effect_power,
					spell_data.status_effect_duration
				])


func find_nearest_enemy() -> void:
	"""Encontra o inimigo mais próximo para homing"""
	if not homing:
		return
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	var nearest_distance = 999999.0
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		
		var distance = global_position.distance_to(enemy.global_position)
		if distance < nearest_distance and distance < 300.0:  # Raio de detecção
			nearest_distance = distance
			target_enemy = enemy


func _on_screen_exited() -> void:
	"""Remove quando sair da tela"""
	queue_free()
