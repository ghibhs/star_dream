extends CharacterBody2D

# ===== DADOS DO BOSS =====
@export var boss_data: EnemyData  # Usa o mesmo EnemyData para compatibilidade

# ===== COMPONENTES =====
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var attack_area: Area2D = $AttackArea2D  # Área de aviso (grande)
@onready var attack_timer: Timer = $AttackTimer
@onready var hit_flash_timer: Timer = $HitFlashTimer

# Barra de vida
var health_bar_background: ColorRect
var health_bar_foreground: ColorRect
var health_bar_container: Control

# Áreas de ataque
var attack_visual: ColorRect = null  # Visual da área de aviso
var damage_area: Area2D = null  # Hitbox real (menor, segue o boss no dash)
var damage_visual: ColorRect = null  # Visual da hitbox

# ===== ESTADO =====
var current_health: float
var player: Node2D = null  # Boss sempre sabe onde está o player
var is_attacking: bool = false
var can_attack: bool = true
var is_dead: bool = false

# ===== ESTADOS DO BOSS =====
enum State { IDLE, WALK, ATTACK, HURT, DEAD }
var current_state: State = State.IDLE


func _ready() -> void:
	add_to_group("enemies")
	add_to_group("bosses")
	print("[BOSS] ⚔️ Boss inicializado!")
	
	if boss_data:
		print("[BOSS] Carregando dados: ", boss_data.enemy_name)
		setup_boss()
	else:
		push_error("Boss EnemyData not assigned!")
		queue_free()
	
	# Boss sempre conhece o player
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		print("[BOSS] 🎯 Player encontrado: ", player.name)
	else:
		print("[BOSS] ⚠️ Player não encontrado!")


func setup_boss() -> void:
	print("[BOSS] ⚙️ Configurando boss...")
	
	# Inicializa health
	current_health = boss_data.max_health
	print("[BOSS]    HP: %.1f/%.1f" % [current_health, boss_data.max_health])
	print("[BOSS]    Dano: %.1f | Defesa: %.1f" % [boss_data.damage, boss_data.defense])
	print("[BOSS]    Velocidade: %.1f" % boss_data.move_speed)
	
	# Configura sprite
	if sprite and boss_data.sprite_frames:
		sprite.sprite_frames = boss_data.sprite_frames
		sprite.scale = boss_data.sprite_scale
		if boss_data.animation_name != "":
			sprite.play(boss_data.animation_name)
		print("[BOSS]    Sprite configurado")
	
	# Configura colisão do corpo
	if collision_shape and boss_data.collision_shape:
		collision_shape.shape = boss_data.collision_shape
		print("[BOSS]    CollisionShape configurado")
	
	# Configura área de ataque (começa desativada)
	if attack_area:
		# Cria shape para a área de ataque
		var attack_collision = CollisionShape2D.new()
		
		if boss_data.attack_hitbox_shape:
			attack_collision.shape = boss_data.attack_hitbox_shape
		else:
			# Fallback: área maior para boss
			var attack_shape = RectangleShape2D.new()
			attack_shape.size = Vector2(60, 80)  # Boss tem área maior
			attack_collision.shape = attack_shape
		
		if "attack_hitbox_offset" in boss_data:
			attack_collision.position = boss_data.attack_hitbox_offset
		else:
			attack_collision.position = Vector2(40, 0)
		
		attack_area.add_child(attack_collision)
		
		# Visual da área de ataque (sempre visível para dash)
		attack_visual = ColorRect.new()
		var shape_size = Vector2.ZERO
		if boss_data.attack_hitbox_shape is RectangleShape2D:
			shape_size = boss_data.attack_hitbox_shape.size
		elif boss_data.attack_hitbox_shape is CircleShape2D:
			var radius = boss_data.attack_hitbox_shape.radius
			shape_size = Vector2(radius * 2, radius * 2)
		
		attack_visual.size = shape_size
		attack_visual.position = boss_data.attack_hitbox_offset - shape_size / 2
		
		# Cor inicial (será mudada durante ataque)
		attack_visual.color = Color(1, 0.5, 0, 0.6)  # Laranja inicial
		
		# Área começa INVISÍVEL
		attack_visual.visible = false
		attack_area.add_child(attack_visual)
		print("[BOSS]    👁️ Área de AVISO criada (grande, invisível)")
		
		# Área de aviso NÃO causa dano (só visual)
		attack_area.monitoring = false
	
	# Cria HITBOX real (menor, segue o boss)
	damage_area = Area2D.new()
	damage_area.name = "DamageArea"
	damage_area.collision_layer = 8
	damage_area.collision_mask = 2
	add_child(damage_area)
	
	var damage_collision = CollisionShape2D.new()
	var damage_shape = RectangleShape2D.new()
	damage_shape.size = Vector2(50, 40)  # Hitbox menor que área de aviso
	damage_collision.shape = damage_shape
	damage_collision.position = Vector2(35, 0)  # Mais próxima do boss
	damage_area.add_child(damage_collision)
	
	# Visual da hitbox (menor)
	damage_visual = ColorRect.new()
	damage_visual.size = Vector2(50, 40)
	damage_visual.position = Vector2(10, -20)  # Centraliza no offset
	damage_visual.color = Color(1, 0, 0, 0.8)  # Vermelho
	damage_visual.visible = false
	damage_area.add_child(damage_visual)
	
	# Começa desativada e invisível
	damage_area.monitoring = false
	damage_area.body_entered.connect(_on_damage_area_body_entered)
	
	print("[BOSS]    💥 Hitbox de DANO criada (pequena, invisível)")
	
	# Configura timer de ataque
	if attack_timer:
		attack_timer.wait_time = boss_data.attack_cooldown
		attack_timer.one_shot = true
		attack_timer.timeout.connect(_on_attack_timer_timeout)
		print("[BOSS]    AttackTimer configurado (cooldown: %.2fs)" % boss_data.attack_cooldown)
	
	# Configura timer de flash de dano
	if hit_flash_timer:
		hit_flash_timer.wait_time = boss_data.hit_flash_duration
		hit_flash_timer.one_shot = true
		hit_flash_timer.timeout.connect(_on_hit_flash_timeout)
		print("[BOSS]    HitFlashTimer configurado")
	
	# Cria barra de vida (maior que inimigos normais)
	create_health_bar()
	
	print("[BOSS] ✅ Boss configurado! Estado: IDLE")


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	match current_state:
		State.IDLE:
			process_idle()
		State.WALK:
			process_walk(delta)
		State.ATTACK:
			process_attack()
		State.HURT:
			process_hurt()
	
	# Move o boss (se não estiver atacando)
	if not is_attacking:
		move_and_slide()


func process_idle() -> void:
	velocity = Vector2.ZERO
	
	# Toca animação idle se existir, senão toca walk parada
	if sprite:
		if boss_data.sprite_frames.has_animation("idle"):
			sprite.play("idle")
		else:
			sprite.play(boss_data.animation_name)
	
	# Boss sempre busca o player
	if player and is_instance_valid(player):
		var distance = global_position.distance_to(player.global_position)
		if distance > boss_data.attack_range:
			current_state = State.WALK
			print("[BOSS] Estado: IDLE → WALK")


func process_walk(_delta: float) -> void:
	if not player or not is_instance_valid(player):
		current_state = State.IDLE
		return
	
	# Toca animação de caminhada
	if sprite and boss_data.sprite_frames.has_animation("walk"):
		if sprite.animation != "walk":
			sprite.play("walk")
	
	# Move em direção ao player
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * get_current_speed()
	
	# Flip horizontal
	if direction.x < 0:
		sprite.flip_h = true
	elif direction.x > 0:
		sprite.flip_h = false
	
	# Verifica distância para ataque
	var distance = global_position.distance_to(player.global_position)
	print("Boss distance: %.1f | range: %.1f | can_attack: %s | is_attacking: %s" % [distance, boss_data.attack_range, can_attack, is_attacking])
	if distance <= boss_data.attack_range and can_attack and not is_attacking:
		current_state = State.ATTACK
		print("[BOSS] Estado: WALK → ATTACK (distância: %.1f)" % distance)


func process_attack() -> void:
	if not player or not is_instance_valid(player):
		current_state = State.IDLE
		return
	
	# Só executa ataque se não estiver já atacando
	print("process_attack called - is_attacking: ", is_attacking, " | can_attack: ", can_attack)
	if not is_attacking and can_attack:
		print("Starting perform_attack()")
		perform_attack()


func process_hurt() -> void:
	velocity = Vector2.ZERO
	# Volta para walk após o flash
	await hit_flash_timer.timeout
	if not is_dead:
		if player and is_instance_valid(player):
			current_state = State.WALK
			print("[BOSS] Estado: HURT → WALK")
		else:
			current_state = State.IDLE


func perform_attack() -> void:
	"""Executa o ataque do boss com área travada"""
	print("perform_attack() EXECUTING")
	is_attacking = true
	can_attack = false
	velocity = Vector2.ZERO  # Para de se mover
	
	print("[BOSS] ⚔️ INICIANDO ATAQUE!")
	print("[BOSS]    Posição travada em: ", global_position)
	
	# Toca animação de ataque (usa attack_animation_name do boss_data)
	var attack_anim = "attack"
	if "attack_animation_name" in boss_data and boss_data.attack_animation_name != "":
		attack_anim = boss_data.attack_animation_name
	
	if sprite and boss_data.sprite_frames.has_animation(attack_anim):
		sprite.play(attack_anim)
		print("[BOSS]    🎬 Animação '%s' iniciada" % attack_anim)
	
	# FASE 1: Fase de mira (warning) - área LARANJA segue o player
	var warning_delay = 0.4  # Tempo para o player ver o ataque vindo
	if "attack_warning_delay" in boss_data:
		warning_delay = boss_data.attack_warning_delay
	
	print("[BOSS]    ⚠️ Fase de mira (LARANJA): %.2fs" % warning_delay)
	
	# Mostra área de ataque em LARANJA
	if attack_visual:
		attack_visual.visible = true
		attack_visual.color = Color(1, 0.5, 0, 0.6)  # LARANJA semi-transparente
		print("[BOSS]    � Área de ataque LARANJA (mirando)")
	
	# Durante warning, área segue o player
	var warning_timer = 0.0
	var delta_time = 0.016  # ~60 FPS
	while warning_timer < warning_delay:
		if player and is_instance_valid(player):
			# Atualiza rotação para seguir player
			var direction_to_player = (player.global_position - global_position).normalized()
			var angle_to_player = direction_to_player.angle()
			attack_area.rotation = angle_to_player
			
			# Flip sprite
			if direction_to_player.x < 0:
				sprite.flip_h = true
			else:
				sprite.flip_h = false
		
		await get_tree().create_timer(delta_time).timeout
		warning_timer += delta_time
	
	# TRAVA o ângulo de ataque
	print("[BOSS]    🔒 ÂNGULO TRAVADO!")
	var locked_angle = attack_area.rotation
	
	# Esconde área de aviso, mostra hitbox
	if attack_visual:
		attack_visual.visible = false
	
	# FASE 2: DASH com hitbox ativa
	if damage_area:
		damage_area.monitoring = true
		damage_area.rotation = locked_angle
		if damage_visual:
			damage_visual.visible = true
		print("[BOSS]    💥 HITBOX DE DANO ATIVADA!")
	
	# DASH na direção do ataque - percorre a distância TOTAL da área de alerta
	var dash_speed = 600.0  # Velocidade do dash
	
	# Calcula distância baseada no tamanho da área de alerta
	var dash_distance = 200.0  # Tamanho da área (200x80)
	if boss_data.attack_hitbox_shape is RectangleShape2D:
		dash_distance = boss_data.attack_hitbox_shape.size.x
	
	var dash_direction = Vector2.RIGHT.rotated(locked_angle)
	
	print("[BOSS]    💨 DASH! Velocidade: %.0f | Distância: %.0f" % [dash_speed, dash_distance])
	
	# Calcula duração do dash baseado na distância
	var dash_duration = dash_distance / dash_speed
	var dash_timer = 0.0
	var dash_delta = 0.016  # ~60 FPS
	
	# BOSS SE MOVE durante o dash (sprite acompanha)
	while dash_timer < dash_duration:
		velocity = dash_direction * dash_speed
		move_and_slide()  # APLICA O MOVIMENTO!
		# Hitbox se move com o boss automaticamente (é child do boss)
		await get_tree().create_timer(dash_delta).timeout
		dash_timer += dash_delta
	
	# Para após o dash
	velocity = Vector2.ZERO
	move_and_slide()  # Aplica a parada
	print("[BOSS]    🛑 Dash concluído, boss parado")
	
	# Mantém hitbox ativa por mais um pouco
	var attack_duration = 0.2
	if "attack_hitbox_duration" in boss_data:
		attack_duration = boss_data.attack_hitbox_duration
	
	print("[BOSS]    ⏱️ Duração adicional do golpe: %.2fs" % attack_duration)
	await get_tree().create_timer(attack_duration).timeout
	
	# FASE 3: RETRAI hitbox e desativa tudo
	if damage_area:
		damage_area.monitoring = false
		if damage_visual:
			damage_visual.visible = false
		print("[BOSS]    🛑 Hitbox de dano desativada e retraída")
	
	# Área de aviso já está invisível
	if attack_visual:
		attack_visual.visible = false
	
	# Inicia cooldown
	if attack_timer:
		attack_timer.start()
		print("[BOSS]    ⏳ Cooldown iniciado: %.2fs" % attack_timer.wait_time)
	
	# Finaliza ataque
	is_attacking = false
	# can_attack será reativado quando attack_timer timeout
	
	# Volta para animação de caminhada ou idle
	if sprite:
		if boss_data.sprite_frames.has_animation("walk"):
			sprite.play("walk")
		else:
			sprite.play(boss_data.animation_name)
	
	# Retorna ao estado de walk
	current_state = State.WALK
	print("[BOSS]    ✅ Ataque concluído - voltando para WALK")


func take_damage(amount: float, should_stun_on_hit: bool = true) -> void:
	if is_dead:
		return
	
	var damage_taken = max(amount - boss_data.defense, 1.0)
	var previous_health = current_health
	current_health -= damage_taken
	
	print("[BOSS] 💔 BOSS RECEBEU DANO!")
	print("[BOSS]    Dano bruto: %.1f | Defesa: %.1f | Dano real: %.1f" % [amount, boss_data.defense, damage_taken])
	print("[BOSS]    HP: %.1f → %.1f (%.1f%%)" % [previous_health, current_health, (current_health/boss_data.max_health)*100])
	
	update_health_bar()
	
	# Boss não é stunado facilmente (só aplica flash)
	if should_stun_on_hit:
		apply_hit_flash()
	
	if current_health <= 0:
		print("[BOSS] ══════════════════════════════════════")
		print("[BOSS] ⚠️⚠️⚠️  BOSS DERROTADO!  ⚠️⚠️⚠️")
		print("[BOSS] ══════════════════════════════════════")
		await get_tree().create_timer(0.1).timeout
		die()
		return
	
	# Boss não entra em estado HURT (muito resistente)
	# Apenas continua atacando/perseguindo


func apply_hit_flash() -> void:
	if sprite and hit_flash_timer:
		sprite.modulate = Color(1, 0.3, 0.3)  # Vermelho intenso
		hit_flash_timer.start()


func _on_hit_flash_timeout() -> void:
	if sprite:
		sprite.modulate = Color(1, 1, 1)


func die() -> void:
	is_dead = true
	current_state = State.DEAD
	is_attacking = false
	
	print("")
	print("[BOSS] ══════════════════════════════════════")
	print("[BOSS] ☠️☠️☠️  BOSS DERROTADO!  ☠️☠️☠️")
	print("[BOSS] ══════════════════════════════════════")
	print("[BOSS]    Nome: %s" % boss_data.enemy_name)
	print("[BOSS]    Recompensas: %d exp | %d moedas" % [boss_data.experience_drop, boss_data.coin_drop])
	print("[BOSS] ══════════════════════════════════════")
	print("")
	
	# Desativa áreas
	if attack_area:
		attack_area.monitoring = false
	
	# Toca animação de morte se existir
	if sprite and boss_data.sprite_frames.has_animation(boss_data.death_animation):
		sprite.play(boss_data.death_animation)
		print("[BOSS]    Animação de morte tocando...")
		await sprite.animation_finished
	else:
		# Aguarda um tempo antes de remover
		await get_tree().create_timer(1.0).timeout
	
	drop_rewards()
	
	# Pode emitir signal de vitória aqui
	if has_node("/root/GameStats"):
		get_node("/root/GameStats").boss_defeated()
	
	print("[BOSS]    Removendo da cena")
	queue_free()


func drop_rewards() -> void:
	print("[BOSS] 💰 Dropando recompensas: %d exp e %d moedas" % [boss_data.experience_drop, boss_data.coin_drop])
	# TODO: Implementar drop de itens especiais


func create_health_bar() -> void:
	"""Cria barra de vida maior para o boss"""
	health_bar_container = Control.new()
	add_child(health_bar_container)
	health_bar_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Posição acima do sprite (ajustar conforme tamanho do boss)
	health_bar_container.position = Vector2(-50, -60)
	health_bar_container.size = Vector2(100, 10)  # Barra maior que inimigos normais
	
	# Background
	health_bar_background = ColorRect.new()
	health_bar_container.add_child(health_bar_background)
	health_bar_background.color = Color(0.1, 0, 0, 0.9)
	health_bar_background.size = Vector2(100, 10)
	health_bar_background.position = Vector2.ZERO
	
	# Foreground
	health_bar_foreground = ColorRect.new()
	health_bar_container.add_child(health_bar_foreground)
	health_bar_foreground.color = Color(1, 0, 0, 1)  # Vermelho para boss
	health_bar_foreground.size = Vector2(100, 10)
	health_bar_foreground.position = Vector2.ZERO
	
	print("[BOSS]    ❤️ Barra de vida criada (maior)")


func update_health_bar() -> void:
	if not health_bar_foreground or not boss_data:
		return
	
	var health_percent = current_health / boss_data.max_health
	health_bar_foreground.size.x = 100 * health_percent
	
	# Cor baseada na vida (vermelho para roxo)
	if health_percent > 0.6:
		health_bar_foreground.color = Color(1, 0, 0, 1)  # Vermelho
	elif health_percent > 0.3:
		health_bar_foreground.color = Color(1, 0.3, 0, 1)  # Laranja
	else:
		health_bar_foreground.color = Color(0.8, 0, 0.8, 1)  # Roxo (crítico)


func _on_attack_area_body_entered(body: Node2D) -> void:
	"""Área de AVISO não causa dano - só visual"""
	pass  # Não faz nada


func _on_damage_area_body_entered(body: Node2D) -> void:
	"""Aplica dano quando player entra na HITBOX real durante o dash"""
	print("[BOSS] 🔔 Hitbox de dano detectou: ", body.name)
	
	if not damage_area or not damage_area.monitoring:
		return
	
	if body.is_in_group("player"):
		print("[BOSS]    💥 Player atingido pelo DASH!")
		
		if body.has_method("take_damage"):
			var applies_kb = boss_data.applies_knockback if "applies_knockback" in boss_data else true
			var kb_force = boss_data.knockback_force if "knockback_force" in boss_data else 500.0  # Boss empurra mais forte
			var kb_duration = boss_data.knockback_duration if "knockback_duration" in boss_data else 0.3
			
			body.take_damage(boss_data.damage, global_position, kb_force, kb_duration, applies_kb)
			print("[BOSS]    ✅ Dano %.1f aplicado pelo dash!" % boss_data.damage)


func _on_attack_timer_timeout() -> void:
	can_attack = true
	print("[BOSS] ⏱️ Cooldown de ataque pronto - can_attack = true")


# ===== SISTEMA DE EFEITOS DE STATUS =====

var is_slowed: bool = false
var slow_multiplier: float = 1.0
var slow_timer: Timer = null

func apply_slow(slow_percent: float, duration: float) -> void:
	if not slow_timer:
		slow_timer = Timer.new()
		add_child(slow_timer)
		slow_timer.timeout.connect(_on_slow_timeout)
		slow_timer.one_shot = true
	
	is_slowed = true
	slow_multiplier = slow_percent
	slow_timer.start(duration)
	
	print("[BOSS] ❄️ Slow aplicado: %.0f%% velocidade" % (slow_percent * 100))


func remove_slow() -> void:
	if is_slowed:
		is_slowed = false
		slow_multiplier = 1.0
		if slow_timer:
			slow_timer.stop()
		print("[BOSS] ✅ Slow removido")


func _on_slow_timeout() -> void:
	remove_slow()


var is_stunned: bool = false
var stun_timer: Timer = null

func apply_stun(duration: float) -> void:
	# Boss é mais resistente a stun (50% de duração)
	var boss_stun_duration = duration * 0.5
	
	if not stun_timer:
		stun_timer = Timer.new()
		add_child(stun_timer)
		stun_timer.timeout.connect(_on_stun_timeout)
		stun_timer.one_shot = true
	
	if not is_stunned:
		is_stunned = true
		velocity = Vector2.ZERO
		print("[BOSS] ⚡ Stunned por %.1fs (50%% resistência)" % boss_stun_duration)
	
	stun_timer.start(boss_stun_duration)


func remove_stun() -> void:
	if is_stunned:
		is_stunned = false
		if stun_timer:
			stun_timer.stop()
		print("[BOSS] ✅ Stun removido")


func _on_stun_timeout() -> void:
	remove_stun()


func get_current_speed() -> float:
	"""Retorna velocidade considerando slow e stun"""
	if is_stunned:
		return 0.0
	return boss_data.move_speed * slow_multiplier
