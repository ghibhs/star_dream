# HitboxComponent.gd
# Componente reutilizável para gerenciar hitboxes de ataque
# Simplifica a lógica de ativação/desativação temporária de áreas de dano
class_name HitboxComponent
extends Area2D

## Sinais
signal hit_landed(target: Node2D)
signal hitbox_activated()
signal hitbox_deactivated()

## Configurações
@export var damage: float = 10.0
@export var hit_duration: float = 0.15  # Quanto tempo a hitbox fica ativa
@export var collision_shape: Shape2D  # Shape da hitbox
@export var hitbox_offset: Vector2 = Vector2(25, 0)  # Posição relativa ao parent
@export var debug_color: Color = Color(1, 0, 0, 0.8)  # Cor no debug
@export var target_group: String = "enemies"  # Grupo alvo (enemies ou player)

## Estado
var is_active: bool = false
var collision_node: CollisionShape2D


func _ready() -> void:
	# Configura a área
	monitoring = false
	monitorable = false
	
	# Cria collision shape
	if collision_shape:
		collision_node = CollisionShape2D.new()
		collision_node.shape = collision_shape
		collision_node.position = hitbox_offset
		collision_node.debug_color = debug_color
		add_child(collision_node)
		DebugLog.verbose("HitboxComponent configurado", "HITBOX")
	else:
		DebugLog.warning("HitboxComponent sem collision_shape!", "HITBOX")
	
	# Conecta sinal
	body_entered.connect(_on_body_entered)


## Ativa a hitbox temporariamente
func activate_hit(duration: float = -1.0) -> void:
	if is_active:
		DebugLog.verbose("Hitbox já está ativa, ignorando", "HITBOX")
		return
	
	var hit_time = duration if duration > 0 else hit_duration
	
	is_active = true
	monitoring = true
	hitbox_activated.emit()
	
	DebugLog.verbose("Hitbox ATIVADA por %.2fs" % hit_time, "HITBOX")
	
	# Torna visual mais brilhante durante ataque
	if collision_node:
		collision_node.debug_color = Color(debug_color.r, debug_color.g, debug_color.b, 0.9)
	
	# Desativa após o tempo
	await get_tree().create_timer(hit_time).timeout
	deactivate_hit()


## Desativa a hitbox
func deactivate_hit() -> void:
	if not is_active:
		return
	
	is_active = false
	monitoring = false
	hitbox_deactivated.emit()
	
	DebugLog.verbose("Hitbox DESATIVADA", "HITBOX")
	
	# Torna visual invisível
	if collision_node:
		collision_node.debug_color = Color(debug_color.r, debug_color.g, debug_color.b, 0.0)


## Rotaciona a hitbox para uma direção
func aim_at_position(target_pos: Vector2, source_pos: Vector2) -> void:
	var direction = (target_pos - source_pos).normalized()
	var angle = direction.angle()
	rotation = angle
	DebugLog.verbose("Hitbox rotacionada: %.1f°" % rad_to_deg(angle), "HITBOX")


## Rotaciona para um ângulo específico
func set_angle(angle_rad: float) -> void:
	rotation = angle_rad


## Atualiza o dano
func set_damage(new_damage: float) -> void:
	damage = new_damage


## Callback de colisão
func _on_body_entered(body: Node2D) -> void:
	if not is_active:
		return
	
	DebugLog.verbose("Hitbox colidiu com: %s" % body.name, "HITBOX")
	
	# Verifica se é do grupo alvo
	if not body.is_in_group(target_group):
		DebugLog.verbose("  └─ Não é do grupo '%s', ignorando" % target_group, "HITBOX")
		return
	
	DebugLog.info("  └─ Alvo válido! Aplicando %.1f de dano" % damage, "HITBOX")
	
	# Tenta aplicar dano
	if body.has_method("take_damage"):
		body.take_damage(damage)
		hit_landed.emit(body)
	elif body.has_node("HealthComponent"):
		var health_comp = body.get_node("HealthComponent") as HealthComponent
		health_comp.take_damage(damage)
		hit_landed.emit(body)
	else:
		DebugLog.warning("  └─ Alvo não tem take_damage() nem HealthComponent!", "HITBOX")
