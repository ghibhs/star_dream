# spell_targeted.gd
extends Node2D
class_name SpellTargeted

## Magia que spawna diretamente no alvo
## Usado para: Relâmpago, Meteoro, Espinhos, etc.

var spell_data: SpellData
var target_enemy: Node2D
var owner_player: Node2D

# Propriedades
var damage: float = 30.0
var spawn_delay: float = 0.5
var warning_duration: float = 0.3

# Visuais
var warning_sprite: Sprite2D
var attack_sprite: AnimatedSprite2D
var impact_particles: GPUParticles2D

# Estado
var is_spawning: bool = true
var spawn_timer: float = 0.0


func _ready() -> void:
	# Sprite de aviso (círculo vermelho no chão)
	warning_sprite = Sprite2D.new()
	add_child(warning_sprite)
	warning_sprite.modulate = Color(1, 0, 0, 0.5)
	# TODO: Adicionar textura de aviso circular
	
	# Sprite do ataque
	attack_sprite = AnimatedSprite2D.new()
	add_child(attack_sprite)
	attack_sprite.visible = false
	
	# Partículas de impacto
	impact_particles = GPUParticles2D.new()
	add_child(impact_particles)
	impact_particles.emitting = false
	impact_particles.one_shot = true
	impact_particles.amount = 30
	impact_particles.lifetime = 0.8
	
	print("[TARGETED] ⚡ Spell targeted criado")


func setup(spell: SpellData, target: Node2D, player: Node2D) -> void:
	"""Configura a magia targeted"""
	spell_data = spell
	target_enemy = target
	owner_player = player
	
	if not target_enemy or not is_instance_valid(target_enemy):
		print("[TARGETED] ❌ Target inválido!")
		queue_free()
		return
	
	# Posiciona no alvo
	global_position = target_enemy.global_position
	
	if spell:
		damage = spell.damage
		spawn_delay = spell.spawn_delay
		warning_duration = spell.warning_duration
		
		# Configura sprite do ataque
		if spell.sprite_frames:
			attack_sprite.sprite_frames = spell.sprite_frames
			attack_sprite.scale = spell.projectile_scale
			
			if spell.animation_name != "":
				attack_sprite.animation = spell.animation_name
			
			print("[TARGETED] 🎨 Sprite configurado")
		
		# Configura cor do aviso
		if "spell_color" in spell:
			warning_sprite.modulate = Color(spell.spell_color.r, spell.spell_color.g, spell.spell_color.b, 0.5)
	
	print("[TARGETED] ⚡ Configurado - Dano: %.1f, Delay: %.1fs" % [damage, spawn_delay])


func _process(delta: float) -> void:
	if not is_spawning:
		return
	
	# Segue o alvo durante o delay
	if target_enemy and is_instance_valid(target_enemy):
		global_position = target_enemy.global_position
	
	# Timer de spawn
	spawn_timer += delta
	
	# Fase de warning
	if spawn_timer < warning_duration:
		# Pulsa o aviso
		var pulse = (sin(spawn_timer * 20.0) + 1.0) / 2.0
		warning_sprite.modulate.a = 0.3 + pulse * 0.4
	
	# Remove aviso antes do spawn
	elif spawn_timer >= warning_duration and warning_sprite.visible:
		warning_sprite.visible = false
	
	# Spawna o ataque
	if spawn_timer >= spawn_delay:
		spawn_attack()


func spawn_attack() -> void:
	"""Spawna o ataque no alvo"""
	is_spawning = false
	
	print("[TARGETED] 💥 SPAWN! Atacando alvo...")
	
	# Mostra sprite do ataque
	attack_sprite.visible = true
	attack_sprite.play()
	
	# Ativa partículas
	impact_particles.emitting = true
	
	# Aplica dano
	if target_enemy and is_instance_valid(target_enemy):
		if target_enemy.has_method("take_damage"):
			target_enemy.take_damage(damage, false)
			print("[TARGETED]    💥 Dano aplicado: %.1f" % damage)
		
		# Aplica status effect
		if spell_data and spell_data.apply_status_effect:
			apply_status_effect(target_enemy)
	
	# Aguarda animação terminar
	if attack_sprite.sprite_frames:
		var animation_length = attack_sprite.sprite_frames.get_animation_length(attack_sprite.animation)
		await get_tree().create_timer(animation_length).timeout
	else:
		await get_tree().create_timer(0.5).timeout
	
	# Remove da cena
	queue_free()


func apply_status_effect(enemy: Node2D) -> void:
	"""Aplica efeito de status no inimigo"""
	if not spell_data:
		return
	
	match spell_data.status_effect_type:
		"slow":
			if enemy.has_method("apply_slow"):
				enemy.apply_slow(spell_data.status_effect_power, spell_data.status_effect_duration)
				print("[TARGETED]    ❄️ Aplicou slow: %.0f%% por %.1fs" % [
					spell_data.status_effect_power * 100,
					spell_data.status_effect_duration
				])
		"stun":
			if enemy.has_method("apply_stun"):
				enemy.apply_stun(spell_data.status_effect_duration)
				print("[TARGETED]    ⚡ Aplicou stun por %.1fs" % spell_data.status_effect_duration)
		"burn":
			if enemy.has_method("apply_burn"):
				enemy.apply_burn(spell_data.status_effect_power, spell_data.status_effect_duration)
				print("[TARGETED]    🔥 Aplicou burn: %.1f dps por %.1fs" % [
					spell_data.status_effect_power,
					spell_data.status_effect_duration
				])


func find_target() -> Node2D:
	"""Encontra o inimigo mais próximo do player"""
	if not owner_player:
		return null
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	var nearest_enemy = null
	var nearest_distance = 999999.0
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		
		var distance = owner_player.global_position.distance_to(enemy.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_enemy = enemy
	
	return nearest_enemy
