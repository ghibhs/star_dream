extends CharacterBody2D

# ===== DADOS DO INIMIGO =====
@export var enemy_data: EnemyData

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
		push_error("EnemyData not assigned!")
		print("[ENEMY] ❌ ERRO: EnemyData não atribuído!")
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
		print("[ENEMY]    Configurando Hitbox...")
		print("[ENEMY]       Collision Layer ANTES: ", hitbox_area.collision_layer)
		print("[ENEMY]       Collision Mask ANTES: ", hitbox_area.collision_mask)
		print("[ENEMY]       Monitoring ANTES: ", hitbox_area.monitoring)
		
		# 🗡️ HITBOX DE ATAQUE: Configurável via EnemyData.tres
		var hitbox_collision = CollisionShape2D.new()
		
		# Usa shape do .tres ou cria padrão
		if enemy_data.attack_hitbox_shape:
			hitbox_collision.shape = enemy_data.attack_hitbox_shape
			print("[ENEMY]       ✅ Usando attack_hitbox_shape do .tres")
		else:
			# Fallback: cria forma padrão
			var attack_shape = RectangleShape2D.new()
			attack_shape.size = Vector2(20, 30)
			hitbox_collision.shape = attack_shape
			print("[ENEMY]       ⚠️ attack_hitbox_shape não definido, usando padrão (20x30)")
		
		# Usa offset do .tres
		if "attack_hitbox_offset" in enemy_data:
			hitbox_collision.position = enemy_data.attack_hitbox_offset
			print("[ENEMY]       Position offset: ", enemy_data.attack_hitbox_offset)
		else:
			hitbox_collision.position = Vector2(25, 0)
			print("[ENEMY]       Position offset: Vector2(25, 0) - padrão")
		
		hitbox_area.add_child(hitbox_collision)
		hitbox_area.body_entered.connect(_on_hitbox_body_entered)
		
		# 🎨 VISUAL: Hitbox SEMPRE VISÍVEL com cor configurável
		var hitbox_color = Color(1, 0, 0, 0.6)  # Vermelho semi-transparente (Enemy = Vermelho)
		if "attack_hitbox_color" in enemy_data:
			hitbox_color = enemy_data.attack_hitbox_color
			# Garante visibilidade mínima
			hitbox_color.a = max(hitbox_color.a, 0.5)
		
		hitbox_collision.debug_color = hitbox_color
		print("[ENEMY]       🎨 Hitbox cor: ", hitbox_color)
		
		# 🛑 IMPORTANTE: Hitbox começa DESATIVADA
		hitbox_area.monitoring = false
		
		print("[ENEMY]    Hitbox de ATAQUE configurada")
		print("[ENEMY]       Layer: ", hitbox_area.collision_layer, " (binário: ", String.num_int64(hitbox_area.collision_layer, 2), ")")
		print("[ENEMY]       Mask: ", hitbox_area.collision_mask, " (binário: ", String.num_int64(hitbox_area.collision_mask, 2), ")")
		print("[ENEMY]       Monitoring: ", hitbox_area.monitoring, " ⚠️ (DESATIVADA - ativa apenas durante ataque)")
		print("[ENEMY]       Shape: ", hitbox_collision.shape.get_class())
		print("[ENEMY]       🎨 Configurações vindas do .tres")
	
	# Configura área de detecção
	if detection_area:
		print("[ENEMY]    Configurando DetectionArea...")
		print("[ENEMY]       Collision Layer ANTES: ", detection_area.collision_layer)
		print("[ENEMY]       Collision Mask ANTES: ", detection_area.collision_mask)
		print("[ENEMY]       Monitoring ANTES: ", detection_area.monitoring)
		
		var detection_shape = CollisionShape2D.new()
		var circle = CircleShape2D.new()
		circle.radius = enemy_data.chase_range
		detection_shape.shape = circle
		detection_area.add_child(detection_shape)
		
		print("[ENEMY]       Shape radius: ", circle.radius)
		print("[ENEMY]       Shape adicionado como filho")
		
		detection_area.body_entered.connect(_on_detection_body_entered)
		detection_area.body_exited.connect(_on_detection_body_exited)
		print("[ENEMY]       Signals conectados")
		
		print("[ENEMY]    DetectionArea configurada (radius: %.1f)" % enemy_data.chase_range)
		print("[ENEMY]    DetectionArea - Layer: %d, Mask: %d" % [detection_area.collision_layer, detection_area.collision_mask])
		print("[ENEMY]    DetectionArea - Monitoring: %s" % detection_area.monitoring)
		print("[ENEMY]    DetectionArea - Monitorable: %s" % detection_area.monitorable)
		
		# Debug: verifica se já existe algum corpo na área
		await get_tree().process_frame  # Espera 1 frame para collision shape estar pronta
		print("[ENEMY]    ⏳ Aguardou 1 frame, verificando overlaps...")
		var bodies_in_area = detection_area.get_overlapping_bodies()
		print("[ENEMY]    🔍 Corpos já na área de detecção: ", bodies_in_area.size())
		for body in bodies_in_area:
			print("[ENEMY]       - ", body.name, " (tipo: ", body.get_class(), ", grupos: ", body.get_groups(), ")")
			if body.is_in_group("player"):
				print("[ENEMY]       ✅ PLAYER DETECTADO no _ready()!")
				target = body
				if current_state == State.IDLE:
					current_state = State.CHASE
					print("[ENEMY]       Estado: IDLE → CHASE")
		
		# Debug: Busca manual do player e calcula distância
		print("[ENEMY]    🔍 Verificação manual de distância...")
		print("[ENEMY]       Posição global do Enemy: ", global_position)
		print("[ENEMY]       Posição global da DetectionArea: ", detection_area.global_position)
		print("[ENEMY]       Posição local da DetectionArea: ", detection_area.position)
		var players = get_tree().get_nodes_in_group("player")
		print("[ENEMY]       Players no grupo: ", players.size())
		if players.size() > 0:
			var player = players[0]
			var distance = global_position.distance_to(player.global_position)
			print("[ENEMY]       Player: ", player.name, " (", player.get_class(), ")")
			print("[ENEMY]       Posição Enemy: ", global_position)
			print("[ENEMY]       Posição Player: ", player.global_position)
			print("[ENEMY]       Distância: %.1f pixels" % distance)
			print("[ENEMY]       Chase Range: %.1f pixels" % enemy_data.chase_range)
			if distance <= enemy_data.chase_range:
				print("[ENEMY]       ✅ Player ESTÁ dentro do range! Deveria ter detectado!")
				print("[ENEMY]       ⚠️ BUG: DetectionArea não está detectando apesar da distância correta!")
			else:
				print("[ENEMY]       ⚠️ Player está FORA do range")
	
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
	
	# Move o inimigo (importante: após os estados aplicarem velocity)
	move_and_slide()


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
	
	# Move em direção ao alvo (usando velocidade com slow aplicado)
	velocity = direction * get_current_speed()
	
	# Flip horizontal baseado na direção
	if direction.x < 0:
		sprite.flip_h = true
	elif direction.x > 0:
		sprite.flip_h = false
	
	# Verifica distância para ataque
	var distance = global_position.distance_to(target.global_position)
	
	# 🔍 DEBUG: Mostra distância a cada segundo aproximadamente
	if Engine.get_frames_drawn() % 60 == 0:  # A cada ~60 frames (1 segundo a 60fps)
		print("[ENEMY] 🏃 CHASE - Distância até player: %.1f / Attack Range: %.1f" % [distance, enemy_data.attack_range])
	
	if distance <= enemy_data.attack_range:
		print("[ENEMY] Estado: CHASE → ATTACK (distância: %.1f)" % distance)
		current_state = State.ATTACK
	
	move_and_slide()


func process_attack() -> void:
	if not target or not is_instance_valid(target):
		print("[ENEMY] Estado: ATTACK → IDLE (alvo perdido)")
		target = null
		current_state = State.IDLE
		return
	
	# 🏃 CONTINUA SE MOVENDO em direção ao player
	var direction = (target.global_position - global_position).normalized()
	velocity = direction * get_current_speed()
	
	# Flip horizontal baseado na direção
	if direction.x < 0:
		sprite.flip_h = true
	elif direction.x > 0:
		sprite.flip_h = false
	
	# Ataca se possível
	if can_attack:
		perform_attack()
	
	# Verifica se alvo saiu do range
	var distance = global_position.distance_to(target.global_position)
	if distance > enemy_data.attack_range:
		print("[ENEMY] Estado: ATTACK → CHASE (alvo fora do range)")
		current_state = State.CHASE
	
	# Move o inimigo
	move_and_slide()


func process_hurt() -> void:
	# Estado de recuo/stun após levar dano
	velocity = Vector2.ZERO
	# Volta para chase após o flash
	await hit_flash_timer.timeout
	if not is_dead:
		# Só volta para chase se tiver alvo
		if target and is_instance_valid(target):
			print("[ENEMY] Estado: HURT → CHASE (flash terminado, alvo válido)")
			current_state = State.CHASE
		else:
			print("[ENEMY] Estado: HURT → IDLE (flash terminado, sem alvo)")
			current_state = State.IDLE


func perform_attack() -> void:
	can_attack = false
	print("[ENEMY] ⚔️ PREPARANDO ATAQUE! (can_attack = false)")
	
	# 🎯 DIRECIONA a hitbox para o player
	if hitbox_area and target and is_instance_valid(target):
		# Calcula direção do player
		var direction_to_player = (target.global_position - global_position).normalized()
		var angle_to_player = direction_to_player.angle()
		
		# Rotaciona a hitbox para apontar ao player
		hitbox_area.rotation = angle_to_player
		print("[ENEMY]    🎯 Hitbox rotacionada para o player (%.1f graus)" % rad_to_deg(angle_to_player))
	
	# Toca animação de ataque se existir
	if sprite and enemy_data.sprite_frames.has_animation("attack"):
		sprite.play("attack")
		print("[ENEMY]    🎬 Animação 'attack' tocando")
	
	# ⏰ DELAY DE AVISO: Tempo para o player esquivar
	var warning_delay = 0.3  # Padrão de 0.3 segundos
	if "attack_warning_delay" in enemy_data:
		warning_delay = enemy_data.attack_warning_delay
		print("[ENEMY]    ⚠️ Delay de aviso: %.2fs (do .tres)" % warning_delay)
	else:
		print("[ENEMY]    ⚠️ Delay de aviso: %.2fs (padrão)" % warning_delay)
	
	# 🟡 Durante o delay, a hitbox fica visível mas NÃO causa dano (aviso visual)
	await get_tree().create_timer(warning_delay).timeout
	
	# ⚡ AGORA SIM ATIVA a hitbox para causar dano
	if hitbox_area:
		hitbox_area.monitoring = true
		print("[ENEMY]    ⚡ Hitbox de GOLPE ATIVADA!")
	
	# Inicia cooldown
	if attack_timer:
		attack_timer.start()
		print("[ENEMY]    ⏳ Cooldown iniciado (%.2fs)" % attack_timer.wait_time)
	
	# 🕐 Usa duração configurada no .tres
	var attack_hit_duration = 0.15
	if "attack_hitbox_duration" in enemy_data:
		attack_hit_duration = enemy_data.attack_hitbox_duration
		print("[ENEMY]    ⏱️ Duração do golpe: %.2fs (do .tres)" % attack_hit_duration)
	else:
		print("[ENEMY]    ⏱️ Duração do golpe: %.2fs (padrão)" % attack_hit_duration)
	
	await get_tree().create_timer(attack_hit_duration).timeout
	
	# 🛑 DESATIVA a hitbox após o golpe rápido
	if hitbox_area:
		hitbox_area.monitoring = false
		print("[ENEMY]    🛑 Hitbox de GOLPE DESATIVADA!")



func take_damage(amount: float) -> void:
	if is_dead:
		print("[ENEMY] ⚠️ Dano ignorado: inimigo já está morto")
		return
	
	# Aplica defesa
	var damage_taken = max(amount - enemy_data.defense, 1.0)
	var previous_health = current_health
	current_health -= damage_taken
	
	print("[ENEMY] 💔 %s RECEBEU DANO!" % enemy_data.enemy_name)
	print("[ENEMY]    Dano bruto: %.1f | Defesa: %.1f | Dano real: %.1f" % [amount, enemy_data.defense, damage_taken])
	print("[ENEMY]    HP: %.1f → %.1f (%.1f%%)" % [previous_health, current_health, (current_health/enemy_data.max_health)*100])
	
	# ✅ SEMPRE aplica o flash vermelho primeiro (mesmo em morte)
	apply_hit_flash()
	
	# Se for agressivo e não tiver alvo, procura o player
	if enemy_data.behavior == "Aggressive" and not target:
		var players = get_tree().get_nodes_in_group("player")
		print("[ENEMY]    🔍 Buscando players no grupo 'player': ", players.size(), " encontrado(s)")
		for p in players:
			print("[ENEMY]       - ", p.name, " (tipo: ", p.get_class(), ")")
		if players.size() > 0:
			target = players[0]
			print("[ENEMY]    🎯 Alvo definido após dano: ", target.name, " (tipo: ", target.get_class(), ")")
			# Verifica se é realmente o CharacterBody2D
			if target.get_class() != "CharacterBody2D":
				print("[ENEMY]    ⚠️ ALERTA: Alvo não é CharacterBody2D!")
	
	# ⚠️ Depois verifica morte
	if current_health <= 0:
		print("[ENEMY] ══════════════════════════════════════")
		print("[ENEMY] ⚠️⚠️⚠️  VIDA ZEROU!  ⚠️⚠️⚠️")
		print("[ENEMY] HP FINAL: %.1f / %.1f" % [current_health, enemy_data.max_health])
		print("[ENEMY] ══════════════════════════════════════")
		print("[ENEMY] ☠️ Aguardando flash antes de morrer...")
		await get_tree().create_timer(0.1).timeout  # Aguarda o flash
		die()
		return
	
	# Se não morreu, muda para estado HURT
	print("[ENEMY] Estado: ", State.keys()[current_state], " → HURT")
	current_state = State.HURT


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
	
	print("")
	print("[ENEMY] ══════════════════════════════════════")
	print("[ENEMY] ☠️☠️☠️  %s MORREU!  ☠️☠️☠️" % enemy_data.enemy_name)
	print("[ENEMY] ══════════════════════════════════════")
	print("[ENEMY]    HP Final: %.1f / %.1f" % [current_health, enemy_data.max_health])
	print("[ENEMY]    Exp drop: %d | Coins drop: %d" % [enemy_data.experience_drop, enemy_data.coin_drop])
	print("[ENEMY] ══════════════════════════════════════")
	print("")
	
	# Contabiliza inimigo derrotado
	if has_node("/root/GameStats"):
		get_node("/root/GameStats").enemy_defeated()
	
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
	print("[ENEMY] 👁️ DetectionArea detectou ENTRADA: ", body.name)
	print("[ENEMY]    Tipo do node: ", body.get_class())
	print("[ENEMY]    Grupos: ", body.get_groups())
	print("[ENEMY]    Behavior do enemy: ", enemy_data.behavior)
	print("[ENEMY]    Estado atual: ", State.keys()[current_state])
	print("[ENEMY]    Tem alvo atual? ", target != null)
	
	if body.is_in_group("player"):
		print("[ENEMY]    ✅ Confirmado: É o PLAYER!")
		if enemy_data.behavior == "Aggressive":
			print("[ENEMY]    ✅ Sou AGRESSIVO! Definindo como alvo...")
			target = body
			if current_state == State.IDLE:
				print("[ENEMY]    Estado: IDLE → CHASE")
				current_state = State.CHASE
			else:
				print("[ENEMY]    Estado já é: ", State.keys()[current_state])
		else:
			print("[ENEMY]    ⚠️ Não sou agressivo (behavior: ", enemy_data.behavior, ")")
	else:
		print("[ENEMY]    ⚠️ NÃO é o player")


func _on_detection_body_exited(body: Node2D) -> void:
	print("[ENEMY] 👁️ DetectionArea saiu: ", body.name)
	if body == target:
		print("[ENEMY]    Era meu alvo! Perdendo alvo e voltando para IDLE")
		target = null
		current_state = State.IDLE


# ===== HITBOX (DANO AO PLAYER) =====
# 🎯 NOVO SISTEMA: Hitbox ativa apenas durante ataque
# Quando player entra na hitbox ATIVA, aplica dano
func _on_hitbox_body_entered(body: Node2D) -> void:
	print("[ENEMY] 🔔 Hitbox detectou entrada: ", body.name)
	
	# Só aplica dano se a hitbox estiver ATIVA (durante ataque)
	if not hitbox_area or not hitbox_area.monitoring:
		print("[ENEMY]    ⚠️ Hitbox inativa, ignorando")
		return
	
	# Verifica se é o player
	if body.is_in_group("player"):
		print("[ENEMY]    💥 Player detectado na hitbox ATIVA!")
		
		# Aplica dano com knockback configurável do EnemyData
		if body.has_method("take_damage"):
			# Usa configurações do .tres
			var applies_kb = enemy_data.applies_knockback if "applies_knockback" in enemy_data else true
			var kb_force = enemy_data.knockback_force if "knockback_force" in enemy_data else 300.0
			var kb_duration = enemy_data.knockback_duration if "knockback_duration" in enemy_data else 0.2
			
			body.take_damage(enemy_data.damage, global_position, kb_force, kb_duration, applies_kb)
			
			if applies_kb:
				print("[ENEMY]    ✅ Dano %.1f aplicado (knockback: %.1f força, %.2fs duração)!" % [enemy_data.damage, kb_force, kb_duration])
			else:
				print("[ENEMY]    ✅ Dano %.1f aplicado (sem knockback)!" % enemy_data.damage)
		else:
			print("[ENEMY]    ❌ Player não tem método take_damage!")
	else:
		print("[ENEMY]    ⚠️ Não é o player, ignorando")


func _on_attack_timer_timeout() -> void:
	can_attack = true
	print("[ENEMY] ⏱️ Cooldown de ataque terminado (can_attack = true)")
	
	# Volta para animação idle/walk
	if sprite and enemy_data.animation_name != "":
		sprite.play(enemy_data.animation_name)
		print("[ENEMY]    Voltando para animação: ", enemy_data.animation_name)


# -----------------------------
# SISTEMA DE SLOW (REDUÇÃO DE VELOCIDADE)
# -----------------------------

var is_slowed: bool = false
var slow_multiplier: float = 1.0
var slow_timer: Timer = null

func apply_slow(slow_percent: float, duration: float) -> void:
	"""Aplica redução de velocidade ao inimigo"""
	# slow_percent: 0.5 = mantém 50% da velocidade (reduz 50%)
	if not is_slowed:
		is_slowed = true
		slow_multiplier = slow_percent  # Ex: 0.5 = mantém 50% da velocidade
		
		# Cria timer se não existe
		if not slow_timer:
			slow_timer = Timer.new()
			add_child(slow_timer)
			slow_timer.timeout.connect(_on_slow_timeout)
			slow_timer.one_shot = false  # Permite renovação
		
		print("[ENEMY] ❄️ Slow aplicado: velocidade reduzida para %.0f%% por %.1fs" % [slow_percent * 100, duration])
	else:
		# Já estava com slow, apenas renova
		pass
	
	# Renova o timer (sempre que é atingido pelo raio)
	slow_timer.start(duration)


func remove_slow() -> void:
	"""Remove o efeito de slow"""
	if is_slowed:
		is_slowed = false
		slow_multiplier = 1.0
		if slow_timer:
			slow_timer.stop()
		print("[ENEMY] ✅ Slow removido")


func _on_slow_timeout() -> void:
	"""Callback quando o slow expira"""
	remove_slow()


func get_current_speed() -> float:
	"""Retorna a velocidade atual considerando slow"""
	return enemy_data.move_speed * slow_multiplier
