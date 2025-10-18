extends CharacterBody2D

# ===== DADOS DO INIMIGO =====
@export var enemy_data: Enemy_Data

# ===== COMPONENTES =====
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hitbox_area: Area2D = $HitboxArea2D
@onready var detection_area: Area2D = $DetectionArea2D
@onready var attack_timer: Timer = $AttackTimer
@onready var hit_flash_timer: Timer = $HitFlashTimer

# ===== ESTADO =====
var current_health: float
var target: Node2D = null
var can_attack: bool = true
var is_dead: bool = false

# ===== ESTADOS DO INIMIGO =====
enum State { IDLE, CHASE, ATTACK, HURT, DEAD }
var current_state: State = State.IDLE


func _ready() -> void:
	add_to_group("enemies")
	print("[ENEMY] Inicializado e adicionado ao grupo 'enemies'")
	
	if enemy_data:
		print("[ENEMY] Carregando dados: ", enemy_data.enemy_name)
		setup_enemy()
	else:
		push_error("Enemy_Data not assigned!")
		print("[ENEMY] ❌ ERRO: Enemy_Data não atribuído!")
		queue_free()


func setup_enemy() -> void:
	print("[ENEMY] ⚙️ Configurando inimigo...")
	
	# Inicializa health
	current_health = enemy_data.max_health
	print("[ENEMY]    HP: %.1f/%.1f" % [current_health, enemy_data.max_health])
	print("[ENEMY]    Dano: %.1f | Defesa: %.1f" % [enemy_data.damage, enemy_data.defense])
	print("[ENEMY]    Velocidade: %.1f" % enemy_data.move_speed)
	print("[ENEMY]    Chase Range: %.1f | Attack Range: %.1f" % [enemy_data.chase_range, enemy_data.attack_range])
	
	# Configura sprite
	if sprite and enemy_data.sprite_frames:
		sprite.sprite_frames = enemy_data.sprite_frames
		sprite.scale = enemy_data.sprite_scale
		if enemy_data.animation_name != "":
			sprite.play(enemy_data.animation_name)
		print("[ENEMY]    Sprite configurado (scale: ", enemy_data.sprite_scale, ")")
	
	# Configura colisão do corpo
	if collision_shape and enemy_data.collision_shape:
		collision_shape.shape = enemy_data.collision_shape
		print("[ENEMY]    CollisionShape configurado")
	
	# Configura hitbox (área que causa dano ao player)
	if hitbox_area and enemy_data.hitbox_shape:
		var hitbox_collision = CollisionShape2D.new()
		hitbox_collision.shape = enemy_data.hitbox_shape
		hitbox_area.add_child(hitbox_collision)
		hitbox_area.body_entered.connect(_on_hitbox_body_entered)
		print("[ENEMY]    Hitbox configurada (Layer: 8, Mask: 2)")
	
	# Configura área de detecção
	if detection_area:
		var detection_shape = CollisionShape2D.new()
		var circle = CircleShape2D.new()
		circle.radius = enemy_data.chase_range
		detection_shape.shape = circle
		detection_area.add_child(detection_shape)
		detection_area.body_entered.connect(_on_detection_body_entered)
		detection_area.body_exited.connect(_on_detection_body_exited)
		print("[ENEMY]    DetectionArea configurada (radius: %.1f)" % enemy_data.chase_range)
	
	# Configura timer de ataque
	if attack_timer:
		attack_timer.wait_time = enemy_data.attack_cooldown
		attack_timer.one_shot = true
		attack_timer.timeout.connect(_on_attack_timer_timeout)
		print("[ENEMY]    AttackTimer configurado (cooldown: %.2fs)" % enemy_data.attack_cooldown)
	
	# Configura timer de flash de dano
	if hit_flash_timer:
		hit_flash_timer.wait_time = enemy_data.hit_flash_duration
		hit_flash_timer.one_shot = true
		hit_flash_timer.timeout.connect(_on_hit_flash_timeout)
		print("[ENEMY]    HitFlashTimer configurado (duração: %.2fs)" % enemy_data.hit_flash_duration)
	
	print("[ENEMY] ✅ Configuração completa! Estado inicial: IDLE")


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	match current_state:
		State.IDLE:
			process_idle()
		State.CHASE:
			process_chase(delta)
		State.ATTACK:
			process_attack()
		State.HURT:
			process_hurt()


func process_idle() -> void:
	# Para de se mover
	velocity = Vector2.ZERO
	
	# Se tiver alvo, muda para chase
	if target and is_instance_valid(target):
		print("[ENEMY] Estado: IDLE → CHASE (alvo detectado)")
		current_state = State.CHASE


func process_chase(_delta: float) -> void:
	if not target or not is_instance_valid(target):
		print("[ENEMY] Estado: CHASE → IDLE (alvo perdido)")
		target = null
		current_state = State.IDLE
		return
	
	# Calcula direção para o alvo
	var direction = (target.global_position - global_position).normalized()
	
	# Move em direção ao alvo
	velocity = direction * enemy_data.move_speed
	
	# Flip horizontal baseado na direção
	if direction.x < 0:
		sprite.flip_h = true
	elif direction.x > 0:
		sprite.flip_h = false
	
	# Verifica distância para ataque
	var distance = global_position.distance_to(target.global_position)
	if distance <= enemy_data.attack_range:
		print("[ENEMY] Estado: CHASE → ATTACK (distância: %.1f)" % distance)
		current_state = State.ATTACK
	
	move_and_slide()


func process_attack() -> void:
	# Para de se mover durante ataque
	velocity = Vector2.ZERO
	
	if not target or not is_instance_valid(target):
		print("[ENEMY] Estado: ATTACK → IDLE (alvo perdido)")
		target = null
		current_state = State.IDLE
		return
	
	# Ataca se possível
	if can_attack:
		perform_attack()
	
	# Verifica se alvo saiu do range
	var distance = global_position.distance_to(target.global_position)
	if distance > enemy_data.attack_range:
		print("[ENEMY] Estado: ATTACK → CHASE (alvo fora do range)")
		current_state = State.CHASE


func process_hurt() -> void:
	# Estado de recuo/stun após levar dano
	velocity = Vector2.ZERO
	# Volta para chase após o flash
	await hit_flash_timer.timeout
	if not is_dead:
		print("[ENEMY] Estado: HURT → CHASE (flash terminado)")
		current_state = State.CHASE


func perform_attack() -> void:
	can_attack = false
	print("[ENEMY] ⚔️ ATACANDO! (can_attack = false)")
	
	# Toca animação de ataque se existir
	if sprite and enemy_data.sprite_frames.has_animation("attack"):
		sprite.play("attack")
		print("[ENEMY]    Animação 'attack' tocando")
	
	# Causa dano ao player (via hitbox collision)
	# O dano é aplicado em _on_hitbox_body_entered
	
	# Inicia cooldown
	if attack_timer:
		attack_timer.start()
		print("[ENEMY]    Cooldown iniciado (%.2fs)" % attack_timer.wait_time)


func take_damage(amount: float) -> void:
	if is_dead:
		print("[ENEMY] ⚠️ Dano ignorado: inimigo já está morto")
		return
	
	# Aplica defesa
	var damage_taken = max(amount - enemy_data.defense, 1.0)
	current_health -= damage_taken
	
	print("[ENEMY] 💔 %s RECEBEU DANO!" % enemy_data.enemy_name)
	print("[ENEMY]    Dano bruto: %.1f | Defesa: %.1f | Dano real: %.1f" % [amount, enemy_data.defense, damage_taken])
	print("[ENEMY]    HP atual: %.1f/%.1f (%.1f%%)" % [current_health, enemy_data.max_health, (current_health/enemy_data.max_health)*100])
	
	# Visual de dano (flash branco)
	apply_hit_flash()
	
	# Muda para estado HURT
	print("[ENEMY] Estado: ", State.keys()[current_state], " → HURT")
	current_state = State.HURT
	
	# Verifica morte
	if current_health <= 0:
		print("[ENEMY] ☠️ HP chegou a 0, iniciando morte...")
		die()


func apply_hit_flash() -> void:
	print("[ENEMY]    🔴 Aplicando flash vermelho")
	if sprite and hit_flash_timer:
		sprite.modulate = Color(1, 0.5, 0.5)  # Vermelho
		hit_flash_timer.start()


func _on_hit_flash_timeout() -> void:
	if sprite:
		sprite.modulate = Color(1, 1, 1)  # Volta ao normal
		print("[ENEMY]    ✅ Flash terminado")


func die() -> void:
	is_dead = true
	current_state = State.DEAD
	
	print("[ENEMY] ☠️☠️☠️ %s MORREU! ☠️☠️☠️" % enemy_data.enemy_name)
	print("[ENEMY]    Exp drop: %d | Coins drop: %d" % [enemy_data.experience_drop, enemy_data.coin_drop])
	
	# Toca animação de morte se existir
	if sprite and enemy_data.sprite_frames.has_animation(enemy_data.death_animation):
		sprite.play(enemy_data.death_animation)
		print("[ENEMY]    Animação de morte tocando...")
		await sprite.animation_finished
		print("[ENEMY]    Animação de morte terminada")
	
	# Drop de rewards (implementar depois)
	drop_rewards()
	
	# Remove da cena
	print("[ENEMY]    Removendo da cena (queue_free)")
	queue_free()


func drop_rewards() -> void:
	# TODO: Implementar sistema de drop (exp, moedas, itens)
	print("[ENEMY] 💰 Dropando recompensas: %d exp e %d moedas" % [enemy_data.experience_drop, enemy_data.coin_drop])


# ===== SIGNALS DE DETECÇÃO =====
func _on_detection_body_entered(body: Node2D) -> void:
	print("[ENEMY] 👁️ DetectionArea detectou: ", body.name)
	print("[ENEMY]    Grupos: ", body.get_groups())
	print("[ENEMY]    Behavior: ", enemy_data.behavior)
	
	if body.is_in_group("player") and enemy_data.behavior == "Aggressive":
		print("[ENEMY]    ✅ É o player e sou agressivo! Definindo como alvo...")
		target = body
		if current_state == State.IDLE:
			print("[ENEMY]    Estado: IDLE → CHASE")
			current_state = State.CHASE
	else:
		print("[ENEMY]    ⚠️ Não atendeu condições (não é player ou não sou agressivo)")


func _on_detection_body_exited(body: Node2D) -> void:
	print("[ENEMY] 👁️ DetectionArea saiu: ", body.name)
	if body == target:
		print("[ENEMY]    Era meu alvo! Perdendo alvo e voltando para IDLE")
		target = null
		current_state = State.IDLE


# ===== HITBOX (DANO AO PLAYER) =====
func _on_hitbox_body_entered(body: Node2D) -> void:
	print("[ENEMY] 💥 Hitbox colidiu com: ", body.name)
	print("[ENEMY]    Grupos: ", body.get_groups())
	print("[ENEMY]    can_attack: ", can_attack)
	
	if body.is_in_group("player") and can_attack:
		print("[ENEMY]    ✅ É o player e pode atacar!")
		# Aplica dano ao player
		if body.has_method("take_damage"):
			print("[ENEMY]    💥 Causando %.1f de dano no player!" % enemy_data.damage)
			body.take_damage(enemy_data.damage)
			print("[ENEMY]    ✅ Dano aplicado com sucesso")
		else:
			print("[ENEMY]    ⚠️ Player não tem método take_damage()")
	else:
		if not body.is_in_group("player"):
			print("[ENEMY]    ⚠️ Não é o player")
		if not can_attack:
			print("[ENEMY]    ⚠️ Ainda em cooldown")


func _on_attack_timer_timeout() -> void:
	can_attack = true
	print("[ENEMY] ⏱️ Cooldown de ataque terminado (can_attack = true)")
	
	# Volta para animação idle/walk
	if sprite and enemy_data.animation_name != "":
		sprite.play(enemy_data.animation_name)
		print("[ENEMY]    Voltando para animação: ", enemy_data.animation_name)
