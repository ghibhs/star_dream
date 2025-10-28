# magic_buff.gd
extends Node2D
class_name MagicBuff

## Sistema de buff/debuff temporário

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var duration_timer: Timer = $Duration
@onready var particles: CPUParticles2D = $ParticleEffect

var spell_data: SpellData
var target_node: Node2D
var original_stats: Dictionary = {}

# Modificadores ativos
var is_active: bool = false


func _ready() -> void:
	if duration_timer:
		duration_timer.timeout.connect(_on_duration_end)
	
	# Configura partículas padrão
	if particles:
		particles.emitting = false
		particles.amount = 30
		particles.lifetime = 1.5
		particles.one_shot = false
		particles.speed_scale = 1.0
		particles.explosiveness = 0.0
		particles.randomness = 0.5
		particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
		particles.emission_sphere_radius = 25.0
		particles.direction = Vector2(0, -1)
		particles.spread = 45.0
		particles.gravity = Vector2(0, -50.0)
		particles.initial_velocity_min = 20.0
		particles.initial_velocity_max = 50.0
		particles.angular_velocity_min = -90.0
		particles.angular_velocity_max = 90.0
		particles.scale_amount_min = 1.0
		particles.scale_amount_max = 2.0
		particles.color = Color.WHITE


func setup(spell: SpellData, target: Node2D) -> void:
	"""Configura o buff baseado no SpellData"""
	spell_data = spell
	target_node = target
	
	if duration_timer:
		duration_timer.wait_time = spell.duration
	
	# Configura visual - AnimatedSprite2D
	if animated_sprite and "buff_sprite_frames" in spell and spell.buff_sprite_frames:
		animated_sprite.sprite_frames = spell.buff_sprite_frames
		animated_sprite.visible = true
		
		# Toca animação
		if "buff_animation" in spell and spell.buff_animation != "":
			animated_sprite.play(spell.buff_animation)
		else:
			animated_sprite.play()
		
		print("[BUFF] 🎨 Tocando animação do buff")
	else:
		if animated_sprite:
			animated_sprite.visible = false
	
	# Configura partículas
	if particles and "spell_color" in spell:
		particles.color = spell.spell_color
	
	# Aplica o buff
	apply_buff()
	
	# Inicia timer e partículas
	if duration_timer:
		duration_timer.start()
	if particles:
		particles.emitting = true
	
	print("[BUFF] ✨ Buff aplicado: %s (Duração: %.1fs)" % [spell.spell_name, spell.duration])


func apply_buff() -> void:
	"""Aplica os modificadores ao alvo"""
	if not target_node:
		push_error("[BUFF] ❌ Target node inválido!")
		return
	
	is_active = true
	
	# Salva valores originais
	if target_node.has("speed") or target_node.has("move_speed"):
		var speed_prop = "move_speed" if target_node.has("move_speed") else "speed"
		original_stats["speed"] = target_node.get(speed_prop)
		original_stats["speed_property"] = speed_prop
	
	# TODO: Salvar outros stats quando implementados
	# if target_node.has("damage_multiplier"):
	#     original_stats["damage"] = target_node.damage_multiplier
	# if target_node.has("defense_multiplier"):
	#     original_stats["defense"] = target_node.defense_multiplier
	
	# Aplica modificadores
	if spell_data.speed_modifier != 1.0 and "speed" in original_stats:
		var speed_prop = original_stats["speed_property"]
		var new_speed = original_stats["speed"] * spell_data.speed_modifier
		target_node.set(speed_prop, new_speed)
		print("[BUFF]    🏃 Velocidade: %.1f → %.1f (%.0f%%)" % [
			original_stats["speed"],
			new_speed,
			spell_data.speed_modifier * 100
		])
	
	if spell_data.damage_modifier != 1.0:
		# TODO: Implementar quando sistema de dano tiver multiplicador
		print("[BUFF]    ⚔️ Dano multiplicador: %.0f%%" % (spell_data.damage_modifier * 100))
	
	if spell_data.defense_modifier != 1.0:
		# TODO: Implementar quando sistema de defesa tiver multiplicador
		print("[BUFF]    🛡️ Defesa multiplicador: %.0f%%" % (spell_data.defense_modifier * 100))


func _process(_delta: float) -> void:
	# Segue o target
	if target_node and is_instance_valid(target_node):
		global_position = target_node.global_position


func _on_duration_end() -> void:
	"""Callback quando o buff expira"""
	remove_buff()
	cleanup()


func remove_buff() -> void:
	"""Remove os modificadores do alvo"""
	if not is_active:
		return
	
	is_active = false
	
	# Restaura valores originais
	if target_node and is_instance_valid(target_node):
		if "speed" in original_stats and "speed_property" in original_stats:
			var speed_prop = original_stats["speed_property"]
			target_node.set(speed_prop, original_stats["speed"])
			print("[BUFF]    🏃 Velocidade restaurada: %.1f" % original_stats["speed"])
		
		# TODO: Restaurar outros stats
	
	print("[BUFF] ⏱️ Buff expirado: %s" % spell_data.spell_name)


func cleanup() -> void:
	"""Limpa o buff da cena"""
	if particles:
		particles.emitting = false
	
	# Aguarda partículas terminarem antes de destruir
	await get_tree().create_timer(particles.lifetime if particles else 0.5).timeout
	queue_free()


func cancel() -> void:
	"""Cancela o buff prematuramente"""
	print("[BUFF] 🚫 Buff cancelado: %s" % spell_data.spell_name)
	
	if duration_timer and duration_timer.is_stopped() == false:
		duration_timer.stop()
	
	remove_buff()
	cleanup()
