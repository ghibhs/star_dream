# melee_attack_component.gd
extends Node2D
class_name MeleeAttackComponent

## Componente especializado para ataques melee
## Gerencia animação, hitbox e aplicação de dano

signal attack_started
signal attack_finished
signal enemy_hit(enemy: Node2D, damage: float)

@export var attack_area: Area2D
@export var weapon_sprite: AnimatedSprite2D
@export var weapon_data: Resource  # WeaponData

var is_attacking: bool = false
var enemies_hit_this_attack: Array = []


func _ready() -> void:
	if attack_area:
		attack_area.monitoring = false


func execute_attack() -> void:
	"""Executa um ataque melee completo"""
	if is_attacking:
		print("[MELEE] ⚠️ Já está atacando, ignorando novo ataque")
		return
	
	if not weapon_data:
		push_error("[MELEE] ❌ WeaponData não configurado!")
		return
	
	is_attacking = true
	enemies_hit_this_attack.clear()
	
	print("[MELEE] 🗡️ Iniciando ataque melee...")
	emit_signal("attack_started")
	
	# Toca animação de ataque
	await play_attack_animation()
	
	# Ativa hitbox
	activate_hitbox()
	
	# Mantém hitbox ativa durante duração do golpe
	await hold_hitbox_active()
	
	# Desativa hitbox
	deactivate_hitbox()
	
	# Volta para animação idle
	play_idle_animation()
	
	is_attacking = false
	print("[MELEE] ✅ Ataque finalizado")
	emit_signal("attack_finished")


func play_attack_animation() -> void:
	"""Toca animação de ataque e aguarda completar"""
	if not weapon_sprite or not weapon_data:
		return
	
	if not weapon_data.sprite_frames:
		print("[MELEE] ⚠️ SpriteFrames não configurado")
		return
	
	if weapon_data.sprite_frames.has_animation("attack"):
		weapon_sprite.play("attack")
		print("[MELEE]    🎬 Tocando animação 'attack'")
		await weapon_sprite.animation_finished
		print("[MELEE]    ✅ Animação concluída")
	else:
		print("[MELEE]    ⚠️ Animação 'attack' não encontrada")
		# Pequeno delay como fallback
		await get_tree().create_timer(0.2).timeout


func activate_hitbox() -> void:
	"""Ativa a hitbox de ataque"""
	if not attack_area:
		push_error("[MELEE] ❌ Attack area não configurada!")
		return
	
	attack_area.monitoring = true
	print("[MELEE]    ✅ Hitbox ATIVADA")


func hold_hitbox_active() -> void:
	"""Mantém hitbox ativa e verifica colisões"""
	var duration = get_hitbox_duration()
	var timer = 0.0
	
	print("[MELEE]    ⏱️ Hitbox ativa por %.2fs" % duration)
	
	while timer < duration:
		await get_tree().process_frame
		timer += get_process_delta_time()
		
		if not attack_area or not attack_area.monitoring:
			break
		
		# Verifica colisões
		check_and_apply_damage()


func check_and_apply_damage() -> void:
	"""Verifica colisões e aplica dano aos inimigos"""
	if not attack_area:
		return
	
	for body in attack_area.get_overlapping_bodies():
		if body.is_in_group("enemies") and body not in enemies_hit_this_attack:
			apply_damage_to_enemy(body)


func apply_damage_to_enemy(enemy: Node2D) -> void:
	"""Aplica dano a um inimigo"""
	enemies_hit_this_attack.append(enemy)
	
	if not enemy.has_method("take_damage"):
		print("[MELEE]    ⚠️ Inimigo %s não tem método take_damage()" % enemy.name)
		return
	
	var damage = get_damage_amount()
	enemy.take_damage(damage)
	
	print("[MELEE]    💥 Dano aplicado a %s: %.1f" % [enemy.name, damage])
	emit_signal("enemy_hit", enemy, damage)


func deactivate_hitbox() -> void:
	"""Desativa a hitbox de ataque"""
	if attack_area:
		attack_area.monitoring = false
		print("[MELEE]    ❌ Hitbox DESATIVADA")


func play_idle_animation() -> void:
	"""Volta para animação idle/padrão"""
	if not weapon_sprite or not weapon_data:
		return
	
	if not weapon_data.sprite_frames:
		return
	
	# Tenta tocar animation_name configurado
	if "animation_name" in weapon_data and weapon_data.animation_name and weapon_data.sprite_frames.has_animation(weapon_data.animation_name):
		weapon_sprite.play(weapon_data.animation_name)
		print("[MELEE]    🔄 Voltando para animação: %s" % weapon_data.animation_name)
	# Fallback para "default"
	elif weapon_data.sprite_frames.has_animation("default"):
		weapon_sprite.play("default")
		print("[MELEE]    🔄 Voltando para animação: default")
	# Sem animação idle, para o sprite
	else:
		weapon_sprite.stop()
		print("[MELEE]    ⏸️ Sprite parado (sem animação idle)")


func get_hitbox_duration() -> float:
	"""Retorna a duração da hitbox ativa"""
	if weapon_data and "attack_hitbox_duration" in weapon_data:
		return weapon_data.attack_hitbox_duration
	return 0.15  # Padrão


func get_damage_amount() -> float:
	"""Retorna o dano do ataque"""
	if weapon_data and "damage" in weapon_data:
		return weapon_data.damage
	return 10.0  # Padrão


func setup(area: Area2D, sprite: AnimatedSprite2D, data: Resource) -> void:
	"""Configura o componente com referências externas"""
	attack_area = area
	weapon_sprite = sprite
	weapon_data = data
	
	if attack_area:
		attack_area.monitoring = false
	
	print("[MELEE] ⚔️ Componente configurado")
	if weapon_data:
		print("[MELEE]    Arma: %s" % weapon_data.item_name)
		print("[MELEE]    Dano: %.1f" % get_damage_amount())
		print("[MELEE]    Duração hitbox: %.2fs" % get_hitbox_duration())
