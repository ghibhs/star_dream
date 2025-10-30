# continuous_beam.gd
extends Node2D
class_name ContinuousBeam

## Sistema de raio contínuo que segue o mouse e aplica dano contínuo
## Usa sprites modulares que se repetem dinamicamente

# ===================================
# CONFIGURAÇÕES DO RAIO
# ===================================
@export_group("Beam Properties")
@export var max_range: float = 800.0  # Alcance máximo do raio
@export var beam_width: float = 32.0  # Largura do raio
@export var damage_per_second: float = 25.0  # Dano por segundo
@export var mana_cost_per_second: float = 10.0  # Custo de mana por segundo

@export_group("Visual Effects")
@export var beam_color: Color = Color(0.3, 0.8, 1.0, 0.8)  # Cor do raio (azul claro)
@export var pulse_speed: float = 3.0  # Velocidade da pulsação
@export var pulse_intensity: float = 0.2  # Intensidade da pulsação (0-1)
@export var oscillation_speed: float = 5.0  # Velocidade da oscilação
@export var oscillation_amplitude: float = 2.0  # Amplitude da oscilação em pixels

@export_group("Collision")
@export var collision_mask: int = 5  # Layer que detecta inimigos

# ===================================
# REFERÊNCIAS DE NODOS
# ===================================
@onready var raycast: RayCast2D = $RayCast2D
@onready var beam_container: Node2D = $BeamContainer
@onready var beam_segment: Sprite2D = $BeamContainer/BeamSegment
@onready var impact_sprite: Sprite2D = $ImpactSprite
@onready var impact_particles: GPUParticles2D = $ImpactParticles
@onready var damage_timer: Timer = $DamageTimer

# ===================================
# VARIÁVEIS DE ESTADO
# ===================================
var is_active: bool = false
var current_target: Node2D = null
var beam_length: float = 0.0
var pulse_time: float = 0.0
var oscillation_time: float = 0.0

# Referência ao player (será definida ao instanciar)
var player: CharacterBody2D = null
var spell_data: SpellData = null

# ===================================
# INICIALIZAÇÃO
# ===================================
func _ready() -> void:
	# Configurar visibilidade inicial
	beam_segment.visible = false
	impact_sprite.visible = false
	
	if impact_particles:
		impact_particles.emitting = false
	
	# Configurar raycast
	raycast.enabled = true
	raycast.target_position = Vector2(max_range, 0)
	raycast.collision_mask = collision_mask
	
	# Configurar timer de dano
	damage_timer.wait_time = 0.2  # Aplica dano 5x por segundo
	damage_timer.timeout.connect(_on_damage_tick)
	
	print("[BEAM] ⚡ Raio contínuo inicializado")

# ===================================
# CONFIGURAÇÃO
# ===================================
func setup(from_player: CharacterBody2D, spell: SpellData) -> void:
	"""Configura o raio com dados do player e spell"""
	player = from_player
	spell_data = spell
	
	if spell_data:
		if spell_data.damage > 0:
			damage_per_second = spell_data.damage
		if spell_data.mana_cost > 0:
			mana_cost_per_second = spell_data.mana_cost
		if spell_data.max_range > 0:
			max_range = spell_data.max_range
			raycast.target_position = Vector2(max_range, 0)
	
	print("[BEAM] 🎯 Configurado - Dano: %.1f/s, Mana: %.1f/s" % [damage_per_second, mana_cost_per_second])

# ===================================
# ATIVAÇÃO E DESATIVAÇÃO
# ===================================
func activate() -> void:
	"""Ativa o raio"""
	if is_active:
		return
	
	is_active = true
	beam_segment.visible = true
	damage_timer.start()
	
	print("[BEAM] ⚡ Raio ATIVADO")

func deactivate() -> void:
	"""Desativa o raio"""
	if not is_active:
		return
	
	is_active = false
	beam_segment.visible = false
	impact_sprite.visible = false
	current_target = null
	damage_timer.stop()
	
	if impact_particles:
		impact_particles.emitting = false
	
	print("[BEAM] 💤 Raio DESATIVADO")

# ===================================
# ATUALIZAÇÃO PRINCIPAL
# ===================================
func _process(delta: float) -> void:
	if not is_active:
		return
	
	# Atualizar direção para o mouse
	update_direction()
	
	# Atualizar raycast e verificar colisão
	update_raycast()
	
	# Atualizar visual do raio
	update_beam_visual(delta)
	
	# Atualizar sprite de impacto
	update_impact_visual()
	
	# Consumir mana
	consume_mana(delta)

# ===================================
# ATUALIZAÇÃO DE DIREÇÃO
# ===================================
func update_direction() -> void:
	"""Atualiza a direção do raio para seguir o mouse"""
	if not player:
		return
	
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()
	
	# Rotacionar o raio
	rotation = direction.angle()

# ===================================
# ATUALIZAÇÃO DO RAYCAST
# ===================================
func update_raycast() -> void:
	"""Atualiza o raycast e detecta colisões"""
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		# Raio colidiu com algo
		var collision_point = raycast.get_collision_point()
		beam_length = global_position.distance_to(collision_point)
		
		# Verificar se é um inimigo
		var collider = raycast.get_collider()
		if collider and collider.is_in_group("enemies"):
			current_target = collider
		else:
			current_target = null
	else:
		# Raio não colidiu, usar alcance máximo
		beam_length = max_range
		current_target = null

# ===================================
# VISUAL DO RAIO
# ===================================
func update_beam_visual(delta: float) -> void:
	"""Atualiza o visual do raio com efeitos de pulsação e oscilação"""
	
	# Atualizar tempo de efeitos
	pulse_time += delta * pulse_speed
	oscillation_time += delta * oscillation_speed
	
	# Calcular pulsação (afeta o brilho/escala)
	var pulse = 1.0 + sin(pulse_time) * pulse_intensity
	
	# Calcular oscilação (movimento senoidal)
	var oscillation = sin(oscillation_time) * oscillation_amplitude
	
	# Ajustar escala do sprite para preencher a distância
	# Assumindo que o sprite original tem largura de 64px
	var sprite_original_width = 64.0
	var scale_x = beam_length / sprite_original_width
	
	beam_segment.scale.x = scale_x * pulse
	beam_segment.scale.y = (beam_width / 32.0) * pulse  # 32 é a altura original
	
	# Aplicar oscilação na posição Y
	beam_segment.position.y = oscillation
	
	# Posicionar o sprite no meio do raio
	beam_segment.position.x = beam_length / 2.0
	
	# Modular cor com pulsação
	var modulated_color = beam_color
	modulated_color.a = beam_color.a * pulse
	beam_segment.modulate = modulated_color

# ===================================
# VISUAL DO IMPACTO
# ===================================
func update_impact_visual() -> void:
	"""Atualiza o sprite de impacto na ponta do raio"""
	
	if beam_length > 0:
		# Mostrar sprite de impacto
		impact_sprite.visible = true
		impact_sprite.global_position = global_position + Vector2(beam_length, 0).rotated(rotation)
		impact_sprite.rotation = rotation
		
		# Ativar partículas se houver colisão com inimigo
		if impact_particles:
			if current_target:
				impact_particles.global_position = impact_sprite.global_position
				impact_particles.rotation = rotation + PI  # Inverter direção
				if not impact_particles.emitting:
					impact_particles.emitting = true
			else:
				impact_particles.emitting = false
	else:
		impact_sprite.visible = false
		if impact_particles:
			impact_particles.emitting = false

# ===================================
# SISTEMA DE DANO
# ===================================
func _on_damage_tick() -> void:
	"""Aplica dano ao alvo a cada tick"""
	if not is_active or not current_target:
		return
	
	# Calcular dano baseado no intervalo do timer
	var damage_amount = damage_per_second * damage_timer.wait_time
	
	# Aplicar dano ao inimigo
	if current_target.has_method("take_damage"):
		current_target.take_damage(damage_amount, global_position)
		print("[BEAM] 💥 Aplicou %.1f de dano em %s" % [damage_amount, current_target.name])
	
	# Verificar se o alvo morreu
	if not is_instance_valid(current_target) or current_target.is_queued_for_deletion():
		current_target = null

# ===================================
# CONSUMO DE MANA
# ===================================
func consume_mana(delta: float) -> void:
	"""Consome mana do player enquanto o raio está ativo"""
	if not player:
		return
	
	var mana_to_consume = mana_cost_per_second * delta
	
	if player.current_mana >= mana_to_consume:
		player.current_mana -= mana_to_consume
		player.mana_changed.emit(player.current_mana)
	else:
		# Sem mana, desativar raio
		print("[BEAM] ⚠️ Mana insuficiente! Desativando raio...")
		deactivate()

# ===================================
# LIMPEZA
# ===================================
func _exit_tree() -> void:
	deactivate()
