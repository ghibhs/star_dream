# HealthComponent.gd
# Componente reutilizável para gerenciar saúde de entidades (player, enemy, etc)
# Anexe este node como filho de qualquer entidade que precisa de saúde
class_name HealthComponent
extends Node

## Sinais para comunicação com o parent
signal health_changed(current: float, maximum: float, percentage: float)
signal damage_taken(amount: float)
signal healed(amount: float)
signal died()

## Configurações
@export var max_health: float = 100.0
@export var defense: float = 0.0  # Reduz dano recebido
@export var hit_flash_duration: float = 0.1  # Duração do flash de dano
@export var invulnerable: bool = false  # Se true, não recebe dano

## Estado atual
var current_health: float
var is_dead: bool = false

## Referência ao sprite para efeito visual (opcional)
var sprite: Node = null


func _ready() -> void:
	current_health = max_health
	DebugLog.info("HealthComponent inicializado: %.1f/%.1f HP" % [current_health, max_health], "HEALTH")
	
	# Tenta encontrar o sprite automaticamente
	_find_sprite()


func _find_sprite() -> void:
	"""Tenta encontrar um AnimatedSprite2D ou Sprite2D no parent"""
	var parent = get_parent()
	if not parent:
		return
	
	# Procura AnimatedSprite2D primeiro
	for child in parent.get_children():
		if child is AnimatedSprite2D:
			sprite = child
			DebugLog.verbose("Sprite encontrado: AnimatedSprite2D", "HEALTH")
			return
	
	# Se não encontrar, procura Sprite2D
	for child in parent.get_children():
		if child is Sprite2D:
			sprite = child
			DebugLog.verbose("Sprite encontrado: Sprite2D", "HEALTH")
			return


## Aplica dano à entidade
func take_damage(amount: float) -> void:
	if is_dead or invulnerable:
		DebugLog.verbose("Dano ignorado (morto ou invulnerável)", "HEALTH")
		return
	
	# Calcula dano real após defesa
	var damage_taken_amount = max(amount - defense, 1.0)  # Mínimo 1 de dano
	current_health -= damage_taken_amount
	current_health = max(current_health, 0.0)  # Não fica negativo
	
	DebugLog.info("Dano recebido: %.1f (bruto: %.1f) | HP: %.1f/%.1f" % 
		[damage_taken_amount, amount, current_health, max_health], "HEALTH")
	
	# Emite sinais
	damage_taken.emit(damage_taken_amount)
	_emit_health_changed()
	
	# Efeito visual
	apply_hit_flash()
	
	# Verifica morte
	if current_health <= 0 and not is_dead:
		_die()


## Cura a entidade
func heal(amount: float) -> void:
	if is_dead:
		DebugLog.verbose("Cura ignorada (está morto)", "HEALTH")
		return
	
	var old_health = current_health
	current_health = min(current_health + amount, max_health)
	var actual_heal = current_health - old_health
	
	if actual_heal > 0:
		DebugLog.info("Curado: %.1f | HP: %.1f/%.1f" % [actual_heal, current_health, max_health], "HEALTH")
		healed.emit(actual_heal)
		_emit_health_changed()


## Define a saúde diretamente (útil para reset/debug)
func set_health(value: float) -> void:
	current_health = clamp(value, 0.0, max_health)
	_emit_health_changed()


## Restaura saúde completa
func reset_health() -> void:
	current_health = max_health
	is_dead = false
	DebugLog.info("Saúde restaurada: %.1f/%.1f" % [current_health, max_health], "HEALTH")
	_emit_health_changed()


## Retorna a porcentagem de saúde (0.0 a 1.0)
func get_health_percentage() -> float:
	if max_health == 0:
		return 0.0
	return current_health / max_health


## Verifica se está com pouca saúde
func is_low_health(threshold: float = 0.3) -> bool:
	return get_health_percentage() <= threshold


## Aplica efeito visual de dano
func apply_hit_flash() -> void:
	if not sprite:
		return
	
	# Flash vermelho
	sprite.modulate = Color(1, 0.3, 0.3)
	
	# Volta ao normal após o timer
	await get_tree().create_timer(hit_flash_duration).timeout
	
	if sprite and is_instance_valid(sprite):
		sprite.modulate = Color(1, 1, 1)


## Função privada para morte
func _die() -> void:
	is_dead = true
	current_health = 0.0
	DebugLog.info("Entidade morreu!", "HEALTH")
	died.emit()


## Emite sinal de mudança de saúde
func _emit_health_changed() -> void:
	var percentage = get_health_percentage()
	health_changed.emit(current_health, max_health, percentage)
