# magic_heal.gd
extends Node2D
class_name MagicHeal

## Sistema de cura (instantânea ou ao longo do tempo)

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var particles: CPUParticles2D = $ParticleEffect
@onready var heal_timer: Timer = $HealTimer
@onready var duration_timer: Timer = $DurationTimer

var spell_data: SpellData
var target_node: Node2D
var total_healed: float = 0.0

# Para Heal over Time (HoT)
var is_hot: bool = false
var heal_per_tick: float = 0.0
var tick_count: int = 0


func _ready() -> void:
	if heal_timer:
		heal_timer.timeout.connect(_on_heal_tick)
	
	if duration_timer:
		duration_timer.timeout.connect(_on_duration_end)
	
	# Configura partículas de cura
	if particles:
		particles.emitting = false
		particles.amount = 40
		particles.lifetime = 2.0
		particles.one_shot = false
		particles.speed_scale = 1.2
		particles.explosiveness = 0.3
		particles.randomness = 0.4
		particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
		particles.emission_sphere_radius = 20.0
		particles.direction = Vector2(0, -1)
		particles.spread = 30.0
		particles.gravity = Vector2(0, -80.0)
		particles.initial_velocity_min = 30.0
		particles.initial_velocity_max = 70.0
		particles.scale_amount_min = 1.5
		particles.scale_amount_max = 3.0
		particles.color = Color(0.2, 1.0, 0.3, 1.0)  # Verde cura


func setup(spell: SpellData, target: Node2D) -> void:
	"""Configura a cura baseado no SpellData"""
	spell_data = spell
	target_node = target
	
	if not target_node:
		push_error("[HEAL] ❌ Target inválido!")
		queue_free()
		return
	
	# Posiciona no target
	global_position = target_node.global_position
	
	# Configura visual - AnimatedSprite2D
	if animated_sprite and "heal_sprite_frames" in spell and spell.heal_sprite_frames:
		animated_sprite.sprite_frames = spell.heal_sprite_frames
		animated_sprite.visible = true
		
		# Toca animação
		if "heal_animation" in spell and spell.heal_animation != "":
			animated_sprite.play(spell.heal_animation)
		else:
			animated_sprite.play()
		
		print("[HEAL] 🎨 Tocando animação de cura")
	else:
		if animated_sprite:
			animated_sprite.visible = false
	
	# Configura cor das partículas
	if particles and "spell_color" in spell:
		particles.color = spell.spell_color
	
	# Verifica se é cura instantânea ou HoT
	is_hot = spell.heal_over_time if "heal_over_time" in spell else false
	
	if is_hot:
		setup_heal_over_time()
	else:
		apply_instant_heal()


func apply_instant_heal() -> void:
	"""Aplica cura instantânea"""
	if not target_node or not is_instance_valid(target_node):
		return
	
	var heal_amount = spell_data.heal_amount
	
	# Verifica se target tem sistema de vida
	if not target_node.has("current_health") or not target_node.has("max_health"):
		push_error("[HEAL] ❌ Target não tem sistema de vida!")
		cleanup()
		return
	
	var old_health = target_node.current_health
	target_node.current_health = min(target_node.current_health + heal_amount, target_node.max_health)
	var actual_heal = target_node.current_health - old_health
	total_healed = actual_heal
	
	# Emite sinal se existir
	if target_node.has_signal("health_changed"):
		target_node.emit_signal("health_changed", target_node.current_health)
	
	print("[HEAL] 💚 Cura instantânea aplicada!")
	print("[HEAL]    Quantidade: +%.1f HP" % actual_heal)
	print("[HEAL]    HP: %.1f/%.1f" % [target_node.current_health, target_node.max_health])
	
	# Ativa partículas
	if particles:
		particles.emitting = true
		particles.one_shot = true
	
	# Remove após partículas terminarem
	cleanup()


func setup_heal_over_time() -> void:
	"""Configura cura ao longo do tempo"""
	var duration = spell_data.heal_duration if "heal_duration" in spell_data else 5.0
	var tick_interval = 0.5  # Tick a cada 0.5s
	
	# Calcula cura por tick
	var total_ticks = int(duration / tick_interval)
	heal_per_tick = spell_data.heal_amount / total_ticks
	
	print("[HEAL] 💚 Iniciando HoT (Heal over Time)")
	print("[HEAL]    Duração: %.1fs" % duration)
	print("[HEAL]    Cura total: %.1f HP" % spell_data.heal_amount)
	print("[HEAL]    Cura por tick: %.1f HP (a cada %.1fs)" % [heal_per_tick, tick_interval])
	
	# Configura timers
	if heal_timer:
		heal_timer.wait_time = tick_interval
		heal_timer.start()
	
	if duration_timer:
		duration_timer.wait_time = duration
		duration_timer.start()
	
	# Ativa partículas contínuas
	if particles:
		particles.emitting = true
		particles.one_shot = false


func _on_heal_tick() -> void:
	"""Callback de cada tick de cura"""
	if not target_node or not is_instance_valid(target_node):
		cleanup()
		return
	
	if not target_node.has("current_health") or not target_node.has("max_health"):
		cleanup()
		return
	
	var old_health = target_node.current_health
	target_node.current_health = min(target_node.current_health + heal_per_tick, target_node.max_health)
	var actual_heal = target_node.current_health - old_health
	total_healed += actual_heal
	tick_count += 1
	
	# Emite sinal
	if target_node.has_signal("health_changed"):
		target_node.emit_signal("health_changed", target_node.current_health)
	
	print("[HEAL]    💚 Tick #%d: +%.1f HP (Total: +%.1f)" % [tick_count, actual_heal, total_healed])


func _process(_delta: float) -> void:
	# Segue o target se for HoT
	if is_hot and target_node and is_instance_valid(target_node):
		global_position = target_node.global_position


func _on_duration_end() -> void:
	"""Callback quando HoT termina"""
	print("[HEAL] ⏱️ HoT finalizado!")
	print("[HEAL]    Total curado: +%.1f HP" % total_healed)
	cleanup()


func cleanup() -> void:
	"""Limpa a cena de cura"""
	# Para timers
	if heal_timer and not heal_timer.is_stopped():
		heal_timer.stop()
	
	if duration_timer and not duration_timer.is_stopped():
		duration_timer.stop()
	
	# Para partículas
	if particles:
		particles.emitting = false
	
	# Aguarda partículas terminarem
	var wait_time = particles.lifetime if particles else 0.5
	await get_tree().create_timer(wait_time).timeout
	queue_free()


func cancel() -> void:
	"""Cancela a cura prematuramente"""
	print("[HEAL] 🚫 Cura cancelada (Total curado até agora: +%.1f HP)" % total_healed)
	cleanup()
