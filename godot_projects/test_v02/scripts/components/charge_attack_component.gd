# charge_attack_component.gd
extends Node2D
class_name ChargeAttackComponent

## Componente para ataques com carregamento (arco, etc)
## Gerencia tempo de carga, indicadores visuais e release

signal charge_started
signal charge_updated(charge_percent: float)
signal charge_released(charge_power: float)
signal charge_maxed

@export var weapon_data: Resource  # WeaponData
@export var charge_indicator_scene: PackedScene

var is_charging: bool = false
var charge_time: float = 0.0
var charge_indicator: Node2D = null
var charge_particles: CPUParticles2D = null
var charge_audio: AudioStreamPlayer2D = null
var has_played_max_sound: bool = false


func _ready() -> void:
	set_process(false)  # Só processa quando carregando


func _process(delta: float) -> void:
	if is_charging:
		update_charge(delta)


func start_charging() -> void:
	"""Inicia o carregamento"""
	if not weapon_data or not can_charge():
		print("[CHARGE] ⚠️ Arma não pode ser carregada")
		return
	
	is_charging = true
	charge_time = 0.0
	has_played_max_sound = false
	set_process(true)
	
	print("[CHARGE] 🏹 Carregamento INICIADO")
	print("[CHARGE]    Min: %.2fs | Max: %.2fs" % [
		get_min_charge_time(),
		get_max_charge_time()
	])
	
	create_charge_indicator()
	emit_signal("charge_started")


func update_charge(delta: float) -> void:
	"""Atualiza o tempo de carregamento"""
	charge_time += delta
	
	# Limita ao tempo máximo
	var max_time = get_max_charge_time()
	if charge_time >= max_time:
		charge_time = max_time
		
		if not has_played_max_sound:
			has_played_max_sound = true
			emit_signal("charge_maxed")
			print("[CHARGE]    ⚡ Carga MÁXIMA atingida!")
	
	# Emite progresso
	var charge_percent = get_charge_percent()
	emit_signal("charge_updated", charge_percent)
	
	# Atualiza indicador visual
	update_charge_indicator()


func release_charge() -> float:
	"""Libera a carga e retorna o poder do ataque"""
	if not is_charging:
		print("[CHARGE] ⚠️ Não está carregando, nada para liberar")
		return 0.0
	
	var charge_power = get_charge_power()
	
	print("[CHARGE] 🎯 Carga LIBERADA!")
	print("[CHARGE]    Tempo: %.2fs" % charge_time)
	print("[CHARGE]    Poder: %.1f%%" % (charge_power * 100))
	
	emit_signal("charge_released", charge_power)
	
	# Limpa estado
	cleanup_charging()
	
	return charge_power


func cancel_charge() -> void:
	"""Cancela o carregamento"""
	if not is_charging:
		return
	
	print("[CHARGE] 🚫 Carregamento CANCELADO")
	cleanup_charging()


func cleanup_charging() -> void:
	"""Limpa estado de carregamento"""
	is_charging = false
	charge_time = 0.0
	has_played_max_sound = false
	set_process(false)
	
	# Remove indicador
	if charge_indicator and is_instance_valid(charge_indicator):
		charge_indicator.queue_free()
		charge_indicator = null


func create_charge_indicator() -> void:
	"""Cria indicador visual de carga"""
	# Remove anterior se existir
	if charge_indicator and is_instance_valid(charge_indicator):
		charge_indicator.queue_free()
	
	# Cria indicador simples (Sprite2D)
	var sprite = Sprite2D.new()
	sprite.name = "ChargeIndicator"
	sprite.z_index = 10
	add_child(sprite)
	charge_indicator = sprite
	
	# TODO: Adicionar partículas e áudio quando necessário
	print("[CHARGE]    ✅ Indicador criado")


func update_charge_indicator() -> void:
	"""Atualiza visual do indicador"""
	if not charge_indicator or not is_instance_valid(charge_indicator):
		return
	
	# Exemplo: mudar opacidade baseado na carga
	var charge_percent = get_charge_percent()
	charge_indicator.modulate.a = charge_percent


func get_charge_percent() -> float:
	"""Retorna porcentagem de carga (0.0 a 1.0)"""
	var max_time = get_max_charge_time()
	if max_time <= 0:
		return 0.0
	
	return clamp(charge_time / max_time, 0.0, 1.0)


func get_charge_power() -> float:
	"""Retorna o poder da carga baseado no tempo"""
	var min_time = get_min_charge_time()
	var max_time = get_max_charge_time()
	
	if charge_time < min_time:
		# Carga mínima (weak shot)
		return 0.3
	
	# Interpola entre carga mínima e máxima
	var charge_range = max_time - min_time
	var effective_time = charge_time - min_time
	var power = clamp(effective_time / charge_range, 0.0, 1.0)
	
	# Escala de 0.5 (min charge) a 1.0 (max charge)
	return 0.5 + (power * 0.5)


func can_charge() -> bool:
	"""Verifica se a arma pode ser carregada"""
	if not weapon_data:
		return false
	
	return "can_charge" in weapon_data and weapon_data.can_charge


func get_min_charge_time() -> float:
	"""Retorna tempo mínimo de carga"""
	if weapon_data and "min_charge_time" in weapon_data:
		return weapon_data.min_charge_time
	return 0.3


func get_max_charge_time() -> float:
	"""Retorna tempo máximo de carga"""
	if weapon_data and "max_charge_time" in weapon_data:
		return weapon_data.max_charge_time
	return 2.0


func setup(data: Resource) -> void:
	"""Configura o componente"""
	weapon_data = data
	
	print("[CHARGE] 🎯 Componente configurado")
	if weapon_data:
		print("[CHARGE]    Arma: %s" % weapon_data.item_name)
		print("[CHARGE]    Pode carregar: %s" % can_charge())
		if can_charge():
			print("[CHARGE]    Min: %.2fs | Max: %.2fs" % [
				get_min_charge_time(),
				get_max_charge_time()
			])
