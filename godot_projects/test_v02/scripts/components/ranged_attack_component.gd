# ranged_attack_component.gd
extends Node2D
class_name RangedAttackComponent

## Componente especializado para ataques ranged/projectile
## Gerencia disparo de projéteis

signal projectile_fired(projectile: Node2D)
signal attack_failed(reason: String)

@export var projectile_scene: PackedScene
@export var spawn_marker: Marker2D
@export var weapon_data: Resource  # WeaponData

var is_firing: bool = false


func _ready() -> void:
	# Carrega cena padrão de projétil se não configurada
	if not projectile_scene:
		projectile_scene = preload("res://scenes/projectiles/projectile.tscn")


func execute_attack(target_position: Vector2) -> void:
	"""Dispara um projétil em direção ao alvo"""
	if is_firing:
		print("[RANGED] ⚠️ Já está disparando, ignorando")
		return
	
	if not validate_attack():
		return
	
	is_firing = true
	
	print("[RANGED] 🏹 Disparando projétil...")
	
	# Calcula direção
	var spawn_pos = get_spawn_position()
	var direction = (target_position - spawn_pos).normalized()
	
	# Cria projétil
	var projectile = create_projectile(spawn_pos, direction)
	
	if projectile:
		print("[RANGED]    ✅ Projétil disparado")
		emit_signal("projectile_fired", projectile)
	else:
		print("[RANGED]    ❌ Falha ao criar projétil")
		emit_signal("attack_failed", "Falha ao instanciar projétil")
	
	is_firing = false


func validate_attack() -> bool:
	"""Valida se o ataque pode ser executado"""
	if not projectile_scene:
		push_error("[RANGED] ❌ Projectile scene não configurada!")
		emit_signal("attack_failed", "Scene não configurada")
		return false
	
	if not spawn_marker:
		push_error("[RANGED] ❌ Spawn marker não configurado!")
		emit_signal("attack_failed", "Spawn marker não encontrado")
		return false
	
	if not weapon_data:
		push_error("[RANGED] ❌ WeaponData não configurado!")
		emit_signal("attack_failed", "WeaponData ausente")
		return false
	
	return true


func create_projectile(spawn_pos: Vector2, direction: Vector2) -> Node2D:
	"""Cria e configura um projétil"""
	var projectile = projectile_scene.instantiate()
	
	if not projectile:
		push_error("[RANGED] ❌ Falha ao instanciar projétil!")
		return null
	
	# Posiciona o projétil
	projectile.global_position = spawn_pos
	
	# Adiciona à cena
	get_tree().current_scene.add_child(projectile)
	
	print("[RANGED]    📍 Spawn: %s" % spawn_pos)
	print("[RANGED]    ➡️ Direção: %s" % direction)
	
	# Configura projétil (deferred para garantir que _ready rode primeiro)
	if projectile.has_method("setup_from_weapon_data"):
		projectile.call_deferred("setup_from_weapon_data", weapon_data, direction)
	else:
		push_error("[RANGED] ⚠️ Projétil não tem método setup_from_weapon_data()!")
	
	return projectile


func get_spawn_position() -> Vector2:
	"""Retorna a posição de spawn do projétil"""
	if spawn_marker:
		return spawn_marker.global_position
	
	# Fallback para posição do componente
	return global_position


func setup(marker: Marker2D, data: Resource, scene: PackedScene = null) -> void:
	"""Configura o componente com referências externas"""
	spawn_marker = marker
	weapon_data = data
	
	if scene:
		projectile_scene = scene
	elif not projectile_scene:
		# Carrega cena padrão
		projectile_scene = preload("res://scenes/projectiles/projectile.tscn")
	
	print("[RANGED] 🏹 Componente configurado")
	if weapon_data:
		print("[RANGED]    Arma: %s" % weapon_data.item_name)
		if "projectile_speed" in weapon_data:
			print("[RANGED]    Velocidade: %.1f" % weapon_data.projectile_speed)
		if "damage" in weapon_data:
			print("[RANGED]    Dano: %.1f" % weapon_data.damage)
