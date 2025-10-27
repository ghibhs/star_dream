extends CharacterBody2D

# -----------------------------
# SINAIS
# -----------------------------
signal health_changed(new_health: float)
signal max_health_changed(new_max_health: float)
signal mana_changed(new_mana: float)
signal max_mana_changed(new_max_mana: float)

# -----------------------------
# MOVIMENTO / ANIMAÇÃO DO PLAYER
# -----------------------------
@export var speed: float = 150.0
@export var sprint_multiplier: float = 1.8  # Multiplicador de velocidade no sprint
@export var dash_speed: float = 500.0  # Velocidade do dash
@export var dash_duration: float = 0.15  # Duração do dash em segundos
@export var dash_cooldown: float = 1.0  # Cooldown entre dashes em segundos

var direction: Vector2 = Vector2.ZERO
var is_sprinting: bool = false
var is_dashing: bool = false
var can_dash: bool = true
var dash_direction: Vector2 = Vector2.ZERO

# Timers para dash
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0

# -----------------------------
# SISTEMA DE SAÚDE DO PLAYER
# -----------------------------
@export var max_health: float = 100.0
var current_health: float
var is_dead: bool = false

# -----------------------------
# SISTEMA DE MANA DO PLAYER
# -----------------------------
@export var max_mana: float = 100.0
@export var mana_regen_rate: float = 5.0  # Mana por segundo
var current_mana: float

# -----------------------------
# SISTEMA DE MAGIAS
# -----------------------------
var available_spells: Array[SpellData] = []  # SpellData resources
var current_spell_index: int = 0
var spell_selector_ui: Control = null  # Referência ao UI de seleção

# -----------------------------
# SISTEMA DE KNOCKBACK (EMPURRÃO)
# -----------------------------
@export var knockback_force: float = 300.0  # Força do empurrão
@export var knockback_duration: float = 0.2  # Duração do empurrão em segundos
var is_being_knocked_back: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

# -----------------------------
# SISTEMA DE INVENTÁRIO
# -----------------------------
var inventory: Inventory
var inventory_ui: InventoryUI
var hotbar: HotbarUI  # Mudado de Hotbar para HotbarUI

func _physics_process(delta: float) -> void:
	# Atualiza timers
	update_dash_timers(delta)
	update_knockback_timer(delta)
	
	# Regenera mana
	regenerate_mana(delta)
	
	# === SISTEMA DE SELEÇÃO DE MAGIAS ===
	# Q - Magia anterior
	if Input.is_action_just_pressed("spell_previous"):
		select_previous_spell()
	
	# E - Próxima magia
	if Input.is_action_just_pressed("spell_next"):
		select_next_spell()
	
	# Botão direito do mouse - Lançar magia
	if Input.is_action_just_pressed("cast_spell"):
		cast_current_spell()
	
	# === SISTEMA DE ATAQUE COM CLIQUE/SEGURAR ===
	# Se o botão de ataque está sendo segurado, conta o tempo
	if is_attack_button_pressed and not is_charging:
		attack_button_held_time += delta
		
		# Se segurou por tempo suficiente E a arma pode carregar, inicia carregamento
		if attack_button_held_time >= CHARGE_START_DELAY:
			if current_weapon_data and current_weapon_data.can_charge:
				print("[PLAYER] 🏹 Tempo de segurar atingido! Iniciando CARREGAMENTO (%.3fs)" % attack_button_held_time)
				start_charging()
				is_attack_button_pressed = false  # Para não entrar aqui novamente
	
	# Atualiza carregamento do arco
	if is_charging:
		update_charge(delta)
		update_charge_indicator()
	
	# Input de movimento
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Sprint (segurar Shift)
	is_sprinting = Input.is_action_pressed("sprint") and direction != Vector2.ZERO
	
	# Dash (pressionar Space)
	if Input.is_action_just_pressed("dash") and can_dash and direction != Vector2.ZERO:
		start_dash()
	
	# Animações
	if direction != Vector2.ZERO and not is_dashing and not is_being_knocked_back:
		play_animations(direction)
	else:
		if animation and not is_dashing:
			animation.stop()

	# Arma aponta pro mouse (caso já tenha arma equipada)
	if current_weapon_data and weapon_marker:
		weapon_marker.look_at(get_global_mouse_position())
		# offset opcional, se o sprite "aponta" para cima/direita diferente do seu:
		if weapon_angle_offset_deg != 0.0:
			weapon_marker.rotation += deg_to_rad(weapon_angle_offset_deg)
		
		# 🔒 Garante que a hitbox de ataque não gire em si mesma
		# A hitbox gira com o weapon_marker, mas mantém rotation local = 0
		if attack_area and is_instance_valid(attack_area):
			attack_area.rotation = 0.0
		
		# 🔄 O sprite da arma é filho do weapon_marker, então rotaciona automaticamente
		# Apenas garantimos que ele está visível e no lugar certo
		if current_weapon_sprite and is_instance_valid(current_weapon_sprite):
			# Se o sprite não é filho do marker por algum motivo, corrige isso
			if current_weapon_sprite.get_parent() != weapon_marker:
				print("[PLAYER] ⚠️ Sprite da arma não é filho do marker! Reparentando...")
				current_weapon_sprite.reparent(weapon_marker)
			# Mantém rotação local = 0 para que apenas o marker controle a rotação
			current_weapon_sprite.rotation = 0.0

	# Calcula velocidade final
	var final_velocity: Vector2
	
	if is_being_knocked_back:
		# Durante knockback, usa a velocidade do empurrão
		final_velocity = knockback_velocity
	elif is_dashing:
		# Durante dash, movimento rápido na direção do dash
		final_velocity = dash_direction * dash_speed
	else:
		# Movimento normal com sprint
		var current_speed = speed
		if is_sprinting:
			current_speed *= sprint_multiplier
		final_velocity = direction * current_speed
	
	velocity = final_velocity
	move_and_slide()


func play_animations(dir: Vector2) -> void:
	if not animation:
		return

	# Seu mapeamento atual de animações (ajuste os nomes se quiser)
	if dir.x > 0 and dir.y == 0:
		animation.play("default")            # → direita
	elif dir.x < 0 and dir.y == 0:
		animation.play("new_animation_3")    # ← esquerda
	elif dir.x == 0 and dir.y < 0:
		animation.play("new_animation_1")    # ↑ cima
	elif dir.x == 0 and dir.y > 0:
		animation.play("new_animation_5")    # ↓ baixo
	elif dir.x > 0 and dir.y < 0:
		animation.play("new_animation")      # ↗
	elif dir.x < 0 and dir.y < 0:
		animation.play("new_animation_2")    # ↖
	elif dir.x < 0 and dir.y > 0:
		animation.play("new_animation_4")    # ↙
	elif dir.x > 0 and dir.y > 0:
		animation.play("new_animation_6")    # ↘


# -----------------------------
# SISTEMA DE SPRINT E DASH
# -----------------------------
func update_dash_timers(delta: float) -> void:
	"""Atualiza os timers do dash"""
	# Timer de duração do dash
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			end_dash()
	
	# Timer de cooldown do dash
	if not can_dash:
		dash_cooldown_timer -= delta
		if dash_cooldown_timer <= 0.0:
			can_dash = true
			print("[PLAYER] 🔄 Dash disponível novamente!")


func start_dash() -> void:
	"""Inicia o dash"""
	if is_dashing or not can_dash:
		return
	
	print("[PLAYER] 💨 DASH iniciado!")
	is_dashing = true
	can_dash = false
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown
	dash_direction = direction.normalized()
	
	# Efeito visual (opcional): pode adicionar partículas ou animação especial aqui


func end_dash() -> void:
	"""Finaliza o dash"""
	print("[PLAYER] ✅ Dash finalizado")
	is_dashing = false
	dash_timer = 0.0


# -----------------------------
# SISTEMA DE KNOCKBACK (EMPURRÃO)
# -----------------------------
func update_knockback_timer(delta: float) -> void:
	"""Atualiza o timer do knockback"""
	if is_being_knocked_back:
		knockback_timer -= delta
		if knockback_timer <= 0.0:
			end_knockback()


func apply_knockback(from_position: Vector2, force: float = 0.0, duration: float = 0.0) -> void:
	"""Aplica empurrão na direção oposta ao atacante"""
	if is_dead:
		return
	
	# Usa força e duração customizadas ou valores padrão do player
	var actual_force = force if force > 0.0 else knockback_force
	var actual_duration = duration if duration > 0.0 else knockback_duration
	
	# Calcula direção do empurrão (do atacante para o player)
	var knockback_direction = (global_position - from_position).normalized()
	
	# Define velocidade do empurrão
	knockback_velocity = knockback_direction * actual_force
	
	# Ativa knockback
	is_being_knocked_back = true
	knockback_timer = actual_duration
	
	print("[PLAYER]    💥 Knockback aplicado!")
	print("[PLAYER]       Direção: ", knockback_direction)
	print("[PLAYER]       Força: %.1f" % actual_force)
	print("[PLAYER]       Duração: %.2fs" % actual_duration)


func end_knockback() -> void:
	"""Finaliza o knockback"""
	is_being_knocked_back = false
	knockback_velocity = Vector2.ZERO
	knockback_timer = 0.0


# -----------------------------
# ARMA / ATAQUE
# -----------------------------
# -----------------------------
# ARMA DO PLAYER
# -----------------------------
var current_weapon_data: WeaponData
@export var weapon_item_scene: PackedScene = preload("res://scenes/items/bow.tscn")  # Cena genérica do item

@export var weapon_angle_offset_deg: float = 0.0   # ajuste fino da rotação do sprite da arma
@onready var weapon_marker: Node2D = $WeaponMarker2D
@onready var projectile_spawn_marker: Marker2D = $WeaponMarker2D/ProjectileSpawnMarker2D
@onready var weapon_timer: Timer = $WeaponMarker2D/Weapon_timer
# O sprite da arma será criado dinamicamente como filho do WeaponMarker2D
var current_weapon_sprite: AnimatedSprite2D = null
@export var fire_rate: float = 3.0  # tiros por segundo (cd = 1 / fire_rate)
var can_attack: bool = true

var attack_area: Area2D

# === SISTEMA DE CARREGAMENTO DO ARCO ===
var is_charging: bool = false
var charge_time: float = 0.0
var attack_button_held_time: float = 0.0  # Tempo que o botão está pressionado
var is_attack_button_pressed: bool = false  # Flag para saber se está segurando
const CHARGE_START_DELAY: float = 0.15  # Tempo mínimo para iniciar carregamento (em segundos)
var charge_indicator: Node2D = null  # Indicador visual de carga
var charge_particles: GPUParticles2D = null  # Partículas de energia
var charge_audio: AudioStreamPlayer2D = null  # Som de carregamento
var charge_max_audio: AudioStreamPlayer2D = null  # Som ao atingir máximo
var has_played_max_sound: bool = false  # Flag para tocar som máximo apenas 1x

func _ready() -> void:
	add_to_group("player")
	print("[PLAYER] Inicializado e adicionado ao grupo 'player'")
	print("[PLAYER]    Nome do node: ", name)
	print("[PLAYER]    Tipo: ", get_class())
	print("[PLAYER]    Collision Layer: ", collision_layer, " (binário: ", String.num_int64(collision_layer, 2), ")")
	print("[PLAYER]    Collision Mask: ", collision_mask, " (binário: ", String.num_int64(collision_mask, 2), ")")
	
	# Verifica CollisionShape2D
	var collision_shape = get_node_or_null("CollisionShape2D")
	if collision_shape:
		print("[PLAYER]    CollisionShape2D encontrado")
		print("[PLAYER]       Disabled: ", collision_shape.disabled)
		print("[PLAYER]       Shape: ", collision_shape.shape)
	else:
		print("[PLAYER]    ⚠️ CollisionShape2D NÃO encontrado!")
	
	# Inicializa saúde
	current_health = max_health
	print("[PLAYER] Saúde inicializada: %.1f/%.1f" % [current_health, max_health])
	emit_signal("health_changed", current_health)
	emit_signal("max_health_changed", max_health)
	
	# Inicializa mana
	current_mana = max_mana
	print("[PLAYER] 🔮 ═══ INICIALIZANDO MANA ═══")
	print("[PLAYER]    Max Mana: %.1f" % max_mana)
	print("[PLAYER]    Current Mana: %.1f" % current_mana)
	print("[PLAYER]    Emitindo sinal mana_changed...")
	emit_signal("mana_changed", current_mana)
	print("[PLAYER]    Emitindo sinal max_mana_changed...")
	emit_signal("max_mana_changed", max_mana)
	print("[PLAYER] ═══════════════════════════════\n")
	
	# Inicializa sistema de magias
	setup_spell_system()
	
	# Inicializa inventário (se existir na cena)
	inventory = get_node_or_null("Inventory")
	inventory_ui = get_node_or_null("InventoryUI")
	hotbar = get_tree().get_first_node_in_group("hotbar_ui")  # Busca hotbar no grupo
	
	if inventory and inventory_ui:
		# Aguarda a UI estar pronta antes de configurar
		await get_tree().process_frame
		inventory_ui.setup_inventory(inventory)
		
		# Conecta ao sinal de uso de itens
		if not inventory.item_used.is_connected(_on_item_used):
			inventory.item_used.connect(_on_item_used)
			print("[PLAYER] ✅ Conectado ao sinal item_used do inventário")
		
		print("[PLAYER] ✅ Sistema de inventário inicializado")
	else:
		if not inventory:
			print("[PLAYER] ⚠️ Nó 'Inventory' não encontrado - adicione à cena do player")
		if not inventory_ui:
			print("[PLAYER] ⚠️ Nó 'InventoryUI' não encontrado - adicione à cena do player")
	
	if hotbar and inventory:
		hotbar.setup_inventory(inventory)
		print("[PLAYER] ✅ Hotbar inicializada")
	elif not hotbar:
		print("[PLAYER] ⚠️ Nó 'Hotbar' não encontrado - adicione à cena do player")
	
	# 🧪 Adiciona itens de teste ao inventário
	if inventory:
		call_deferred("_add_test_items")
	
	# Inicia contagem de estatísticas
	if has_node("/root/GameStats"):
		get_node("/root/GameStats").start_game()
		print("[PLAYER] Sistema de estatísticas iniciado")
	
	# Configura timer de cooldown
	if weapon_timer:
		weapon_timer.wait_time = 1.0 / fire_rate  # Valor padrão (será sobrescrito pela arma)
		weapon_timer.one_shot = true
		weapon_timer.timeout.connect(_on_weapon_timer_timeout)
		print("[PLAYER] Timer de ataque configurado (cooldown será definido pela arma equipada)")
	# Armas melee não rotacionam para o mouse


func _input(event: InputEvent) -> void:
	# ⚠️ Bloqueia ataques se inventário estiver aberto
	var inventory_is_open = inventory_ui and inventory_ui.is_open
	if inventory_is_open:
		return  # Ignora todos os inputs se inventário estiver aberto
	
	# === SISTEMA DE CARREGAMENTO DO ARCO ===
	if event.is_action_pressed("attack"):
		print("[PLAYER] 🎯 Botão de ataque PRESSIONADO")
		
		# Verifica se pode atacar
		if not can_attack or not weapon_timer.is_stopped():
			if not can_attack:
				print("[PLAYER] ⚠️ Ataque bloqueado: can_attack = false")
			if not weapon_timer.is_stopped():
				print("[PLAYER] ⚠️ Ataque bloqueado: timer ainda ativo (%.2fs restantes)" % weapon_timer.time_left)
			return
		
		# Marca que o botão foi pressionado e inicia o contador
		is_attack_button_pressed = true
		attack_button_held_time = 0.0
		print("[PLAYER] ⏱️ Iniciando contagem de tempo de pressionamento...")
	
	elif event.is_action_released("attack"):
		print("[PLAYER] 🎯 Botão de ataque SOLTO")
		
		# Se estava carregando, dispara com o poder acumulado
		if is_charging:
			print("[PLAYER] 🏹 Disparando arco carregado!")
			release_charged_attack()
		# Se soltou rápido (antes do delay), dispara normal
		elif is_attack_button_pressed and attack_button_held_time < CHARGE_START_DELAY:
			print("[PLAYER] ⚔️ Clique rápido detectado! Ataque instantâneo (%.3fs)" % attack_button_held_time)
			perform_attack()
		
		# Reseta flags
		is_attack_button_pressed = false
		attack_button_held_time = 0.0


func receive_weapon_data(weapon_data: WeaponData) -> void:
	# Recebido do item coletável
	print("[PLAYER] 🗡️ Arma recebida: ", weapon_data.item_name)
	print("[PLAYER]    Tipo: ", weapon_data.weapon_type)
	print("[PLAYER]    Dano: ", weapon_data.damage)
	
	# TODO: Integração com inventário (precisa criar ItemData wrapper para WeaponData)
	# Por enquanto, mantém comportamento antigo
	
	# Se já temos uma arma equipada, dropa ela no mundo
	if current_weapon_data:
		print("[PLAYER] 🔄 Já existe arma equipada! Dropando arma antiga...")
		drop_current_weapon()
	
	# Equipa a nova arma
	current_weapon_data = weapon_data
	call_deferred("setup_weapon")


func drop_current_weapon() -> void:
	"""
	Dropa a arma atual no mundo próximo ao player
	"""
	if not current_weapon_data:
		print("[PLAYER] ⚠️ Tentou dropar arma mas não há arma equipada")
		return
	
	print("[PLAYER] 📦 Dropando arma: ", current_weapon_data.item_name)
	
	# Cria instância do item no mundo
	var dropped_item = weapon_item_scene.instantiate() as Area2D
	
	if dropped_item:
		# Posição de drop: um pouco à frente do player (na direção que ele está olhando)
		var drop_offset = Vector2(50, 0)  # 50 pixels à direita
		if direction != Vector2.ZERO:
			# Se o player está se movendo, dropa na direção oposta
			drop_offset = -direction.normalized() * 50
		
		dropped_item.global_position = global_position + drop_offset
		
		# ⚠️ IMPORTANTE: Configura o item ANTES de adicionar à árvore (evita glitch)
		dropped_item.initialize_dropped_item(current_weapon_data)
		
		# Adiciona ao mundo (mesma cena que o player)
		get_parent().add_child(dropped_item)
		
		print("[PLAYER]    ✅ Arma dropada na posição: ", dropped_item.global_position)
	else:
		push_error("[PLAYER] ❌ Falha ao instanciar item dropado")
	
	# Limpa o slot de equipamento no inventário
	if inventory:
		inventory.equipment_slots[ItemData.EquipmentSlot.WEAPON_PRIMARY] = null
		inventory.equipment_changed.emit(ItemData.EquipmentSlot.WEAPON_PRIMARY)
		print("[PLAYER] 🗑️ Slot de arma limpo no inventário")


func setup_weapon() -> void:
	if not current_weapon_data:
		print("[PLAYER] ⚠️ setup_weapon() chamado sem weapon_data")
		return

	print("[PLAYER] Configurando arma: ", current_weapon_data.item_name)
	# NÃO destruímos o sprite da arma — ele já está na cena para você poder editar escala no editor.
	# Apenas atualizamos os dados visuais e os pontos auxiliares.
	setup_weapon_marker_position()
	create_or_update_weapon_sprite()
	setup_attack_area()
	setup_projectile_spawn()
	
	# Adiciona arma ao slot de equipamento visual do inventário
	update_weapon_in_equipment_slot()
	
	print("[PLAYER] ✅ Arma configurada com sucesso")


func update_weapon_in_equipment_slot() -> void:
	"""Atualiza o slot visual de equipamento WEAPON_PRIMARY com a arma atual"""
	if not inventory:
		return
	
	if current_weapon_data and current_weapon_data.icon:
		# Cria um ItemData temporário para display visual apenas
		var weapon_item = ItemData.new()
		weapon_item.item_name = current_weapon_data.item_name
		weapon_item.icon = current_weapon_data.icon
		weapon_item.item_type = ItemData.ItemType.WEAPON
		weapon_item.equipment_slot = ItemData.EquipmentSlot.WEAPON_PRIMARY
		weapon_item.is_stackable = false
		
		# Atualiza o slot de equipamento
		inventory.equipment_slots[ItemData.EquipmentSlot.WEAPON_PRIMARY] = weapon_item
		inventory.equipment_changed.emit(ItemData.EquipmentSlot.WEAPON_PRIMARY)
		
		print("[PLAYER] 🗡️ Arma adicionada ao slot de equipamento: ", current_weapon_data.item_name)
	else:
		# Remove arma do slot se não houver arma equipada
		inventory.equipment_slots[ItemData.EquipmentSlot.WEAPON_PRIMARY] = null
		inventory.equipment_changed.emit(ItemData.EquipmentSlot.WEAPON_PRIMARY)
		print("[PLAYER] ❌ Slot de arma limpo")


func setup_weapon_marker_position() -> void:
	# Configura posição do weapon_marker (ponto de rotação da arma)
	if weapon_marker and current_weapon_data:
		if "weapon_marker_position" in current_weapon_data:
			weapon_marker.position = current_weapon_data.weapon_marker_position
		else:
			weapon_marker.position = Vector2.ZERO  # Posição padrão


func create_or_update_weapon_sprite() -> void:
	# Remove sprite antigo se existir
	if current_weapon_sprite != null and is_instance_valid(current_weapon_sprite):
		print("[PLAYER] Removendo sprite de arma anterior")
		current_weapon_sprite.queue_free()
		current_weapon_sprite = null
	
	# Cria novo sprite como filho do weapon_marker
	if weapon_marker:
		current_weapon_sprite = AnimatedSprite2D.new()
		weapon_marker.add_child(current_weapon_sprite)
		print("[PLAYER] Novo sprite de arma criado como filho do WeaponMarker2D")
	else:
		push_error("[PLAYER] WeaponMarker2D não existe!")
		return
	
	# Atualiza frames e animação
	if current_weapon_data.sprite_frames:
		current_weapon_sprite.sprite_frames = current_weapon_data.sprite_frames
		print("[PLAYER]    Sprite frames configurados")
	
	if current_weapon_data.animation_name != "":
		current_weapon_sprite.play(current_weapon_data.animation_name)
		print("[PLAYER]    Tocando animação: ", current_weapon_data.animation_name)

	# Configura escala da arma (se definido no Resource)
	if "Sprite_scale" in current_weapon_data and current_weapon_data.Sprite_scale != Vector2.ZERO:
		current_weapon_sprite.scale = current_weapon_data.Sprite_scale
		print("[PLAYER]    Scale: ", current_weapon_sprite.scale)
	
	# Configura posição local do sprite (offset relativo ao marker)
	if "sprite_position" in current_weapon_data and current_weapon_data.sprite_position != Vector2.ZERO:
		current_weapon_sprite.position = current_weapon_data.sprite_position
		print("[PLAYER]    Position: ", current_weapon_sprite.position)
	else:
		# Posição padrão (centro do marker)
		current_weapon_sprite.position = Vector2.ZERO
		print("[PLAYER]    Position: Vector2.ZERO (padrão)")
	
	# IMPORTANTE: Rotação local sempre 0, o marker controla a rotação
	current_weapon_sprite.rotation = 0.0
	print("[PLAYER] ✅ Sprite da arma configurado e pronto para rotacionar com o mouse")
	

func setup_attack_area() -> void:
	# Limpa hitbox antiga (se existir)
	if attack_area and is_instance_valid(attack_area):
		print("[PLAYER] Removendo hitbox antiga")
		attack_area.queue_free()
		attack_area = null

	# Cria hitbox apenas se a arma possuir colisão de melee
	if current_weapon_data.attack_collision:
		print("[PLAYER] Criando hitbox de melee...")
		attack_area = Area2D.new()
		attack_area.collision_layer = 16  # Layer 5: Player Hitbox
		attack_area.collision_mask = 4    # Mask 3: Detecta Enemy
		
		# 🗡️ HITBOX DE ATAQUE: Configurável via WeaponData.tres
		var collision_shape := CollisionShape2D.new()
		
		# Usa shape do .tres ou cria padrão
		if "attack_hitbox_shape" in current_weapon_data and current_weapon_data.attack_hitbox_shape:
			collision_shape.shape = current_weapon_data.attack_hitbox_shape
			print("[PLAYER]    ✅ Usando attack_hitbox_shape do .tres")
		else:
			# Fallback: cria forma baseada no tipo de arma
			var attack_shape = RectangleShape2D.new()
			if current_weapon_data.weapon_type == "melee":
				attack_shape.size = Vector2(40, 15)  # Linha de corte
			else:
				attack_shape.size = Vector2(25, 25)
			collision_shape.shape = attack_shape
			print("[PLAYER]    ⚠️ attack_hitbox_shape não definido, usando padrão")
		
		attack_area.add_child(collision_shape)
		
		# Usa offset do .tres
		if "attack_hitbox_offset" in current_weapon_data:
			attack_area.position = current_weapon_data.attack_hitbox_offset
			print("[PLAYER]    Hitbox offset: ", current_weapon_data.attack_hitbox_offset)
		elif "attack_collision_position" in current_weapon_data:
			attack_area.position = current_weapon_data.attack_collision_position
			print("[PLAYER]    Hitbox position (fallback): ", current_weapon_data.attack_collision_position)
		else:
			attack_area.position = Vector2(30, 0)
			print("[PLAYER]    Hitbox position: Vector2(30, 0) - padrão")
		
		# 🎨 VISUAL: Hitbox SEMPRE VISÍVEL com cor configurável
		var hitbox_color = Color(0, 1, 0, 0.6)  # Verde semi-transparente (Player = Verde)
		if "attack_hitbox_color" in current_weapon_data:
			hitbox_color = current_weapon_data.attack_hitbox_color
			# Garante visibilidade mínima
			hitbox_color.a = max(hitbox_color.a, 0.5)
		
		collision_shape.debug_color = hitbox_color
		print("[PLAYER]    🎨 Hitbox cor: ", hitbox_color)

		# Coloca a hitbox como filha do marker da arma
		if weapon_marker:
			weapon_marker.add_child(attack_area)
		
		# 🔒 IMPORTANTE: Hitbox não deve rotacionar em si mesma
		# A rotação vem do weapon_marker (pai), então mantemos rotation = 0
		attack_area.rotation = 0.0
		
		print("[PLAYER]    Hitbox shape: ", current_weapon_data.attack_collision)
		print("[PLAYER]    Layer: 16, Mask: 4")

		# Conexões e estado
		attack_area.body_entered.connect(_on_attack_hit)
		attack_area.monitoring = false  # fica off; liga durante o golpe


func setup_projectile_spawn() -> void:
	if projectile_spawn_marker and current_weapon_data:
		# Offset configurável no recurso
		projectile_spawn_marker.position = current_weapon_data.projectile_spawn_offset


func perform_attack() -> void:
	if not current_weapon_data:
		print("[PLAYER] ⚠️ Tentou atacar sem arma equipada")
		return
	if not can_attack:
		print("[PLAYER] ⚠️ Ataque bloqueado: ainda em cooldown")
		return  # ainda em cooldown
	
	print("[PLAYER] ⚔️ ATACANDO com ", current_weapon_data.item_name)
	print("[PLAYER]    Tipo: ", current_weapon_data.weapon_type)
	
	# Desabilita ataques durante cooldown
	can_attack = false

	# --- dispara conforme o tipo ---
	match current_weapon_data.weapon_type:
		"melee":
			print("[PLAYER]    → Executando ataque melee")
			melee_attack()
		"projectile":
			print("[PLAYER]    → Disparando projétil")
			projectile_attack()
		_:
			print("[PLAYER]    → Tipo desconhecido, usando melee como fallback")
			melee_attack()  # fallback
	
	# Inicia cooldown usando o valor do WeaponData
	if weapon_timer:
		var cooldown_time = current_weapon_data.attack_cooldown if current_weapon_data else (1.0 / fire_rate)
		weapon_timer.wait_time = cooldown_time
		weapon_timer.start()
		print("[PLAYER]    Cooldown iniciado: %.2fs (do WeaponData)" % weapon_timer.wait_time)


func melee_attack() -> void:
	if not attack_area:
		print("[PLAYER] ⚠️ Ataque melee cancelado: attack_area não existe")
		return
	
	print("[PLAYER] 🗡️ Executando ataque melee...")
	
	# 🎯 A rotação já é feita pelo weapon_marker no _process
	# Não rotacionar a attack_area separadamente para evitar dupla rotação
	
	# 🎬 ANIMAÇÃO: Toca animação de ataque na arma
	if current_weapon_sprite and current_weapon_data:
		if current_weapon_data.sprite_frames.has_animation("attack"):
			current_weapon_sprite.play("attack")
			print("[PLAYER]    ✅ Tocando animação: 'attack'")
			
			# Aguarda animação completar antes de ativar hitbox
			await current_weapon_sprite.animation_finished
			print("[PLAYER]    ✅ Animação 'attack' finalizada")
		else:
			print("[PLAYER]    ⚠️ Animação 'attack' não encontrada no SpriteFrames")
	
	# ⚔️ ATIVA hitbox (só depois da animação)
	attack_area.monitoring = true
	print("[PLAYER]    ✅ Hitbox de GOLPE ATIVADA!")
	
	# Lista de inimigos já atingidos (para garantir dano único)
	var enemies_hit = []
	
	# ⚡ Duração da hitbox ativa
	var attack_hit_duration = 0.15
	if "attack_hitbox_duration" in current_weapon_data:
		attack_hit_duration = current_weapon_data.attack_hitbox_duration
		print("[PLAYER]    ⏱️ Duração do golpe: %.2fs (do .tres)" % attack_hit_duration)
	else:
		print("[PLAYER]    ⏱️ Duração do golpe: %.2fs (padrão)" % attack_hit_duration)
	
	# Verifica colisões durante a duração da hitbox
	var timer = 0.0
	while timer < attack_hit_duration:
		await get_tree().process_frame
		timer += get_process_delta_time()
		
		# ✅ Verifica se monitoring está ativo antes de pegar overlapping bodies
		if not attack_area.monitoring:
			break
		
		# Verifica inimigos colidindo
		for body in attack_area.get_overlapping_bodies():
			if body.is_in_group("enemies") and body not in enemies_hit:
				enemies_hit.append(body)
				# Aplica dano
				if body.has_method("take_damage"):
					var damage_amount = current_weapon_data.damage if current_weapon_data else 10.0
					body.take_damage(damage_amount)
					print("[PLAYER]    💥 Dano aplicado a ", body.name, ": ", damage_amount)
	
	# Desativa hitbox
	attack_area.monitoring = false
	print("[PLAYER]    ❌ Hitbox de GOLPE DESATIVADA!")
	
	# Volta para animação idle/default
	if current_weapon_sprite and current_weapon_data:
		# Verifica se existe a animação antes de tocar
		if current_weapon_data.sprite_frames.has_animation(current_weapon_data.animation_name):
			current_weapon_sprite.play(current_weapon_data.animation_name)
			print("[PLAYER]    🔄 Voltando para animação: ", current_weapon_data.animation_name)
		elif current_weapon_data.sprite_frames.has_animation("default"):
			current_weapon_sprite.play("default")
			print("[PLAYER]    🔄 Voltando para animação: default")
		else:
			current_weapon_sprite.stop()
			print("[PLAYER]    ⏸️ Sprite parado (sem animação idle)")


func projectile_attack() -> void:
	print("[PLAYER] 🏹 Disparando projétil...")
	var scene := preload("res://scenes/projectiles/projectile.tscn")
	if not scene or not projectile_spawn_marker:
		print("[PLAYER] ⚠️ Projétil cancelado: scene ou spawn_marker inválido")
		return

	var projectile := scene.instantiate()
	projectile.global_position = projectile_spawn_marker.global_position
	print("[PLAYER]    Spawn position: ", projectile_spawn_marker.global_position)

	# Entra na árvore primeiro para garantir que _ready/@onready do projétil rodem
	get_tree().current_scene.add_child(projectile)
	print("[PLAYER]    Projétil adicionado à cena")

	# Direção para o mouse
	var dir: Vector2 = (get_global_mouse_position() - projectile.global_position).normalized()
	print("[PLAYER]    Direção: ", dir)

	# Passa os dados DEPOIS (deferred) — evita Nil no AnimatedSprite2D do projétil
	projectile.call_deferred("setup_from_weapon_data", current_weapon_data, dir)
	print("[PLAYER]    ✅ Projétil configurado e disparado")


# ========================================
# SISTEMA DE CARREGAMENTO DO ARCO
# ========================================

func start_charging() -> void:
	"""Inicia o carregamento do arco"""
	if not current_weapon_data or not current_weapon_data.can_charge:
		print("[PLAYER] ⚠️ Arma não pode ser carregada")
		return
	
	is_charging = true
	charge_time = 0.0
	has_played_max_sound = false
	
	print("[PLAYER] 🏹 Carregamento INICIADO")
	print("[PLAYER]    Tempo mínimo: %.2fs" % current_weapon_data.min_charge_time)
	print("[PLAYER]    Tempo máximo: %.2fs" % current_weapon_data.max_charge_time)
	
	# Cria indicador visual de carga (inclui partículas e sons)
	create_charge_indicator()


func create_charge_indicator() -> void:
	"""Cria o indicador visual de carregamento"""
	# Remove indicador anterior se existir
	if charge_indicator:
		charge_indicator.queue_free()
	
	# Cria novo indicador usando Sprite2D para visualização simples
	var sprite = Sprite2D.new()
	sprite.name = "ChargeIndicator"
	sprite.z_index = 10
	add_child(sprite)
	
	charge_indicator = sprite
	
	# === 🎨 PARTÍCULAS DE ENERGIA ===
	# DESABILITADO TEMPORARIAMENTE - Causava travamentos
	# create_charge_particles()
	
	# === 🎵 SONS DE CARREGAMENTO ===
	create_charge_audio()
	
	print("[PLAYER]    ✅ Indicador de carga criado")


func update_charge(delta: float) -> void:
	"""Atualiza o tempo de carregamento"""
	if not is_charging:
		return
	
	charge_time += delta
	
	# Limita ao tempo máximo
	if charge_time >= current_weapon_data.max_charge_time:
		charge_time = current_weapon_data.max_charge_time
		print("[PLAYER] ⚡ CARGA MÁXIMA ATINGIDA!")


func release_charged_attack() -> void:
	"""Dispara o ataque carregado"""
	if not is_charging:
		return
	
	print("[PLAYER] 🎯 LIBERANDO ATAQUE CARREGADO")
	print("[PLAYER]    Tempo carregado: %.2fs" % charge_time)
	
	# Verifica se atingiu o tempo mínimo
	if charge_time < current_weapon_data.min_charge_time:
		print("[PLAYER] ⚠️ Tempo de carga insuficiente (mínimo: %.2fs)" % current_weapon_data.min_charge_time)
		cancel_charge()
		return
	
	# Calcula o multiplicador de dano baseado no tempo de carga
	var charge_ratio = (charge_time - current_weapon_data.min_charge_time) / (current_weapon_data.max_charge_time - current_weapon_data.min_charge_time)
	charge_ratio = clamp(charge_ratio, 0.0, 1.0)
	
	var damage_multiplier = lerp(current_weapon_data.min_damage_multiplier, current_weapon_data.max_damage_multiplier, charge_ratio)
	var speed_multiplier = lerp(1.0, current_weapon_data.charge_speed_multiplier, charge_ratio)
	
	print("[PLAYER]    Porcentagem de carga: %.1f%%" % (charge_ratio * 100))
	print("[PLAYER]    Multiplicador de dano: %.2fx" % damage_multiplier)
	print("[PLAYER]    Multiplicador de velocidade: %.2fx" % speed_multiplier)
	
	# Aplica efeito de câmera baseado no nível de carga
	camera_shake_on_release(charge_ratio)
	
	# Dispara o projétil com dano e velocidade aumentados
	fire_charged_projectile(damage_multiplier, speed_multiplier)
	
	# Finaliza o carregamento
	end_charge()
	
	# Inicia cooldown
	can_attack = false
	if weapon_timer:
		var cooldown_time = current_weapon_data.attack_cooldown if current_weapon_data else 0.5
		weapon_timer.wait_time = cooldown_time
		weapon_timer.start()
		print("[PLAYER]    Cooldown iniciado: %.2fs" % cooldown_time)


func fire_charged_projectile(damage_mult: float, speed_mult: float) -> void:
	"""Dispara um projétil com modificadores de carga"""
	print("[PLAYER] 🏹 Disparando projétil CARREGADO...")
	var scene := preload("res://scenes/projectiles/projectile.tscn")
	if not scene or not projectile_spawn_marker:
		print("[PLAYER] ⚠️ Projétil cancelado: scene ou spawn_marker inválido")
		return

	var projectile := scene.instantiate()
	projectile.global_position = projectile_spawn_marker.global_position
	
	# Adiciona à cena
	get_tree().current_scene.add_child(projectile)
	
	# Direção para o mouse
	var dir: Vector2 = (get_global_mouse_position() - projectile.global_position).normalized()
	
	# Cria uma cópia temporária do WeaponData com valores modificados
	var modified_weapon_data = current_weapon_data.duplicate()
	modified_weapon_data.damage *= damage_mult
	modified_weapon_data.projectile_speed *= speed_mult
	
	print("[PLAYER]    Dano modificado: %.1f (base: %.1f)" % [modified_weapon_data.damage, current_weapon_data.damage])
	print("[PLAYER]    Velocidade modificada: %.1f (base: %.1f)" % [modified_weapon_data.projectile_speed, current_weapon_data.projectile_speed])
	
	# Configura o projétil
	projectile.call_deferred("setup_from_weapon_data", modified_weapon_data, dir)
	print("[PLAYER]    ✅ Projétil carregado disparado!")


func cancel_charge() -> void:
	"""Cancela o carregamento sem disparar"""
	print("[PLAYER] ❌ Carregamento cancelado")
	end_charge()


func end_charge() -> void:
	"""Finaliza o estado de carregamento"""
	is_charging = false
	charge_time = 0.0
	has_played_max_sound = false
	
	# Remove indicador visual
	if charge_indicator:
		charge_indicator.queue_free()
		charge_indicator = null
	
	# Remove partículas
	# DESABILITADO TEMPORARIAMENTE - Partículas não estão sendo criadas
	# if is_instance_valid(charge_particles):
	# 	charge_particles.emitting = false
	# 	# Remove após as partículas terminarem
	# 	get_tree().create_timer(2.0).timeout.connect(func():
	# 		if is_instance_valid(charge_particles):
	# 			charge_particles.queue_free()
	# 	)
	# 	charge_particles = null
	
	# Para o som de carregamento
	if is_instance_valid(charge_audio):
		charge_audio.stop()
		charge_audio.queue_free()
		charge_audio = null
	
	print("[PLAYER]    Carregamento finalizado")


func update_charge_indicator() -> void:
	"""Atualiza o indicador visual de carregamento"""
	if not charge_indicator or not current_weapon_data:
		return
	
	if not charge_indicator is Sprite2D:
		return
	
	# Calcula progresso (0.0 a 1.0)
	var progress = 0.0
	if charge_time >= current_weapon_data.min_charge_time:
		var charge_range = current_weapon_data.max_charge_time - current_weapon_data.min_charge_time
		var actual_charge = charge_time - current_weapon_data.min_charge_time
		progress = clamp(actual_charge / charge_range, 0.0, 1.0)
	
	# Escala o indicador baseado no progresso (cresce de 1.0 a 2.0)
	var scale_value = lerp(1.0, 2.0, progress)
	charge_indicator.scale = Vector2(scale_value, scale_value)
	
	# Cor muda de amarelo para laranja/vermelho quando carregado
	var color = current_weapon_data.charge_color.lerp(Color.ORANGE_RED, progress)
	charge_indicator.modulate = color
	
	# Rotaciona o indicador
	charge_indicator.rotation += 0.1
	
	# === 🎵 SOM DE CARGA MÁXIMA ===
	if progress >= 1.0 and not has_played_max_sound:
		play_charge_max_sound()
		has_played_max_sound = true
	
	# === 🎨 PARTÍCULAS AUMENTAM COM PROGRESSO ===
	# DESABILITADO TEMPORARIAMENTE - Causava travamentos
	# if charge_particles and charge_particles.process_material:
	# 	charge_particles.amount = int(lerp(10, 50, progress))
	# 	var mat = charge_particles.process_material as ParticleProcessMaterial
	# 	if mat:
	# 		mat.initial_velocity_min = lerp(50, 150, progress)
	# 		mat.initial_velocity_max = lerp(100, 200, progress)
	
	# Adiciona brilho quando carga está completa
	if progress >= 1.0:
		# Efeito de pulso
		var pulse = abs(sin(Time.get_ticks_msec() * 0.005)) * 0.3 + 0.7
		charge_indicator.modulate.a = pulse


# ========================================
# SISTEMA DE PARTÍCULAS DE CARGA
# ========================================

func create_charge_particles() -> void:
	"""Cria as partículas de energia durante o carregamento"""
	# Remove partículas anteriores
	if charge_particles:
		charge_particles.queue_free()
	
	# Cria novo sistema de partículas
	var particles = GPUParticles2D.new()
	particles.name = "ChargeParticles"
	particles.z_index = 5
	add_child(particles)
	
	# Configurações do emissor
	particles.amount = 20
	particles.lifetime = 0.8
	particles.preprocess = 0.5
	particles.explosiveness = 0.0
	particles.randomness = 0.5
	particles.local_coords = true
	particles.emitting = true
	
	# Cria material de partículas
	var particle_material = ParticleProcessMaterial.new()
	
	# Configuração da emissão
	particle_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	particle_material.emission_sphere_radius = 30.0
	
	# Direção e gravidade
	particle_material.direction = Vector3(0, -1, 0)
	particle_material.spread = 180.0
	particle_material.gravity = Vector3(0, 0, 0)
	
	# Velocidade (propriedades corretas do Godot 4.x)
	particle_material.initial_velocity_min = 50.0
	particle_material.initial_velocity_max = 100.0
	
	# Escala (propriedades corretas do Godot 4.x)
	particle_material.scale_min = 0.5
	particle_material.scale_max = 1.5
	
	# Cor (amarelo brilhante)
	particle_material.color = Color(1, 1, 0, 0.8)
	
	# Fade out usando curva
	var fade_curve = Curve.new()
	fade_curve.add_point(Vector2(0, 1))
	fade_curve.add_point(Vector2(1, 0))
	particle_material.alpha_curve = fade_curve
	
	particles.process_material = particle_material
	
	charge_particles = particles
	
	print("[PLAYER]    ✨ Partículas de carga criadas")


# ========================================
# SISTEMA DE ÁUDIO DE CARGA
# ========================================

func create_charge_audio() -> void:
	"""Cria os players de áudio para carregamento"""
	# Som de carregamento contínuo
	charge_audio = AudioStreamPlayer2D.new()
	charge_audio.name = "ChargeAudio"
	charge_audio.bus = "SFX"
	add_child(charge_audio)
	
	# Cria som procedural de carregamento (tom crescente)
	var charge_stream = create_charge_sound()
	if charge_stream:
		charge_audio.stream = charge_stream
		charge_audio.play()
		print("[PLAYER]    🎵 Som de carregamento iniciado")
	
	# Som de carga máxima (será criado depois)
	charge_max_audio = AudioStreamPlayer2D.new()
	charge_max_audio.name = "ChargeMaxAudio"
	charge_max_audio.bus = "SFX"
	add_child(charge_max_audio)


func create_charge_sound() -> AudioStream:
	"""Cria som procedural de carregamento"""
	# Nota: Idealmente usaria AudioStreamGenerator, mas por simplicidade
	# vamos retornar null e adicionar sons reais depois
	# Por enquanto, o sistema está preparado para receber os AudioStreams
	return null


func play_charge_max_sound() -> void:
	"""Toca som quando atinge carga máxima"""
	if charge_max_audio and charge_max_audio.stream:
		charge_max_audio.play()
		print("[PLAYER]    ⚡ Som de CARGA MÁXIMA!")
	
	# === 📳 VIBRAÇÃO (se disponível) ===
	if Input.is_joy_known(0):
		Input.start_joy_vibration(0, 0.3, 0.3, 0.2)


func stop_charge_audio() -> void:
	"""Para os sons de carregamento"""
	if charge_audio and charge_audio.playing:
		charge_audio.stop()
	
	print("[PLAYER]    🔇 Som de carregamento parado")


# ========================================
# EFEITOS DE CÂMERA
# ========================================

func apply_camera_effects(charge_progress: float) -> void:
	"""Aplica efeitos de câmera baseados no progresso"""
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return
	
	# Zoom suave quando carregado
	var target_zoom = lerp(1.0, 1.15, charge_progress)
	camera.zoom = camera.zoom.lerp(Vector2(target_zoom, target_zoom), 0.1)


func camera_shake_on_release(charge_level: float = 1.0) -> void:
	"""Aplica shake na câmera ao disparar (intensidade baseada no nível de carga)"""
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return
	
	# Intensidade do shake baseada no nível de carga
	var shake_amount = lerp(2.0, 8.0, charge_level)
	var shake_duration = lerp(0.15, 0.4, charge_level)
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Número de tremidas baseado no nível
	var shake_count = int(lerp(5.0, 15.0, charge_level))
	
	# Shake aleatório
	for i in range(shake_count):
		var random_offset = Vector2(
			randf_range(-shake_amount, shake_amount),
			randf_range(-shake_amount, shake_amount)
		)
		tween.tween_property(camera, "offset", random_offset, shake_duration / shake_count)
	
	# Volta ao normal
	tween.chain().tween_property(camera, "offset", Vector2.ZERO, 0.1)
	
	print("[PLAYER]    📹 Camera shake aplicado! (intensidade: %.1f%%)" % (charge_level * 100))


func _on_attack_hit(body: Node) -> void:
	print("[PLAYER] 💥 Hitbox colidiu com: ", body.name)
	print("[PLAYER]    Grupos: ", body.get_groups())
	if body.is_in_group("enemies"):
		print("[PLAYER]    ✅ É um inimigo! Aplicando dano...")
		apply_damage_to_target(body)
	else:
		print("[PLAYER]    ⚠️ Não é um inimigo, ignorando")


func apply_damage_to_target(target: Node) -> void:
	if current_weapon_data == null:
		print("[PLAYER] ⚠️ Dano cancelado: sem arma equipada")
		return
	if target.has_method("take_damage"):
		print("[PLAYER] 💥 Causando %.1f de dano em %s" % [current_weapon_data.damage, target.name])
		target.take_damage(current_weapon_data.damage)
		print("[PLAYER]    ✅ Dano aplicado com sucesso")
	else:
		print("[PLAYER]    ⚠️ Alvo não tem método take_damage()")


func _on_weapon_timer_timeout() -> void:
	can_attack = true
	print("[PLAYER] ⏱️ Cooldown terminado, can_attack = true")


# ===== SISTEMA DE SAÚDE =====
func _ready_health() -> void:
	current_health = max_health


func take_damage(amount: float, attacker_position: Vector2 = Vector2.ZERO, kb_force: float = 0.0, kb_duration: float = 0.0, apply_kb: bool = true) -> void:
	if is_dead:
		print("[PLAYER] ⚠️ Dano ignorado: player já está morto")
		return
	
	var previous_health = current_health
	current_health -= amount
	print("[PLAYER] 💔 DANO RECEBIDO: %.1f" % amount)
	print("[PLAYER]    HP: %.1f → %.1f (%.1f%%)" % [previous_health, current_health, (current_health/max_health)*100])
	
	# Aplica flash vermelho (sempre, mesmo se morrer)
	apply_hit_flash()
	
	# ⚠️ VERIFICA MORTE
	if current_health <= 0:
		print("[PLAYER] ══════════════════════════════════════")
		print("[PLAYER] ⚠️⚠️⚠️  VIDA ZEROU!  ⚠️⚠️⚠️")
		print("[PLAYER] HP FINAL: %.1f / %.1f" % [current_health, max_health])
		print("[PLAYER] ══════════════════════════════════════")
		# Aguarda o flash terminar antes de morrer
		await get_tree().create_timer(0.1).timeout
		die()
		return
	
	# Aplica knockback se configurado (apenas se sobreviveu)
	if apply_kb and attacker_position != Vector2.ZERO:
		apply_knockback(attacker_position, kb_force, kb_duration)


func apply_hit_flash() -> void:
	print("[PLAYER]    🔴 Aplicando flash vermelho")
	if animation:
		animation.modulate = Color(1, 0.3, 0.3)  # Vermelho
		await get_tree().create_timer(0.1).timeout
		animation.modulate = Color(1, 1, 1)  # Volta ao normal
		print("[PLAYER]    ✅ Flash terminado")


func die() -> void:
	is_dead = true
	print("")
	print("[PLAYER] ══════════════════════════════════════")
	print("[PLAYER] ☠️☠️☠️  PLAYER MORREU!  ☠️☠️☠️")
	print("[PLAYER] ══════════════════════════════════════")
	print("[PLAYER]    HP Final: %.1f / %.1f" % [current_health, max_health])
	print("[PLAYER]    Physics desativado")
	print("[PLAYER] ══════════════════════════════════════")
	print("")
	
	# Para o movimento
	set_physics_process(false)
	velocity = Vector2.ZERO
	
	# Para estatísticas
	if has_node("/root/GameStats"):
		get_node("/root/GameStats").stop_game()
	
	# Aguarda um pouco antes de mostrar a tela de Game Over
	await get_tree().create_timer(1.5).timeout
	
	# Carrega e mostra a tela de Game Over
	show_game_over()


func show_game_over() -> void:
	print("[PLAYER] 📺 Mostrando tela de Game Over")
	print("[PLAYER] 🔄 VERSÃO NOVA - Trocando cena inteira (não add_child)")
	
	# Para o jogo (já está pausado pelo die())
	if has_node("/root/GameStats"):
		get_node("/root/GameStats").stop_game()
		print("[PLAYER]    GameStats.stop_game() chamado")
	
	# Aguarda um frame para garantir que tudo foi processado
	print("[PLAYER]    Aguardando 1 frame...")
	await get_tree().process_frame
	print("[PLAYER]    Frame processado, iniciando troca de cena")
	
	# TROCA a cena para o Game Over (não adiciona como filho!)
	var game_over_path = "res://scenes/ui/game_over.tscn"
	
	if ResourceLoader.exists(game_over_path):
		print("[PLAYER]    Arquivo encontrado: ", game_over_path)
		print("[PLAYER]    Chamando change_scene_to_file()...")
		get_tree().change_scene_to_file(game_over_path)
		print("[PLAYER] ✅ change_scene_to_file() executado!")
	else:
		push_error("Não foi possível encontrar: " + game_over_path)
		print("[PLAYER] ❌ ERRO: Arquivo não encontrado!")


# -----------------------------
# 🧪 FUNÇÃO DE TESTE - ADICIONA ITENS AO INVENTÁRIO
# -----------------------------
func _add_test_items() -> void:
	"""Adiciona items de teste ao inventário"""
	print("\n[PLAYER] 🧪 _add_test_items() CHAMADA!")
	print("[PLAYER]    Inventory existe? %s" % (inventory != null))
	
	if not inventory:
		print("[PLAYER]    ❌ INVENTORY É NULL! Abortando...")
		return
	
	print("[PLAYER]    ✅ Inventory OK, carregando items...")
	
	# Carrega todos os items
	var health_potion = load("res://resources/items/health_potion.tres")
	var mana_potion = load("res://resources/items/mana_potion.tres")
	var stamina_potion = load("res://resources/items/stamina_potion.tres")
	var speed_elixir = load("res://resources/items/speed_elixir.tres")
	var strength_potion = load("res://resources/items/strength_potion.tres")
	var mega_health = load("res://resources/items/mega_health_potion.tres")
	
	# Adiciona items variados
	if health_potion:
		inventory.add_item(health_potion, 5)
		print("[PLAYER]    ✅ 5x Poção de Vida")
	
	if mana_potion:
		inventory.add_item(mana_potion, 3)
		print("[PLAYER]    ✅ 3x Poção de Mana")
	
	if stamina_potion:
		inventory.add_item(stamina_potion, 4)
		print("[PLAYER]    ✅ 4x Poção de Stamina")
	
	if speed_elixir:
		inventory.add_item(speed_elixir, 2)
		print("[PLAYER]    ✅ 2x Elixir de Velocidade")
	
	if strength_potion:
		inventory.add_item(strength_potion, 2)
		print("[PLAYER]    ✅ 2x Poção de Força")
	
	if mega_health:
		inventory.add_item(mega_health, 1)
		print("[PLAYER]    ✅ 1x Mega Poção de Vida")
	
	print("[PLAYER] ✅ _add_test_items() FINALIZADA!\n")


# -----------------------------
# 🍷 SISTEMA DE CONSUMÍVEIS
# -----------------------------
func _on_item_used(item: ItemData) -> void:
	"""Callback quando um item é usado do inventário"""
	print("\n[PLAYER] ═══════════════════════════════════")
	print("[PLAYER] 🍷 USANDO CONSUMÍVEL")
	print("[PLAYER] ═══════════════════════════════════")
	
	if not item:
		print("[PLAYER] ❌ Item é NULL!")
		return
	
	print("[PLAYER]    Item: %s" % item.item_name)
	print("[PLAYER]    Tipo: %s" % ItemData.ItemType.keys()[item.item_type])
	print("[PLAYER]    HP atual: %.1f / %.1f" % [current_health, max_health])
	
	# Restaura vida
	if item.restore_health > 0:
		var healed = min(item.restore_health, max_health - current_health)
		var old_health = current_health
		current_health += healed
		print("[PLAYER]    💚 Restaurando vida:")
		print("[PLAYER]       Antes: %.1f" % old_health)
		print("[PLAYER]       Curado: +%.0f" % healed)
		print("[PLAYER]       Depois: %.1f / %.1f" % [current_health, max_health])
		
		# Atualiza HUD se existir
		if has_node("PlayerHUD"):
			get_node("PlayerHUD").update_health(current_health, max_health)
			print("[PLAYER]       HUD atualizado")
		else:
			print("[PLAYER]       ⚠️ PlayerHUD não encontrado")
	else:
		print("[PLAYER]    ⚪ Sem restauração de HP")
	
	# Restaura mana (se tiver sistema de mana)
	if item.restore_mana > 0:
		print("[PLAYER]    💙 +%.0f Mana (sistema não implementado)" % item.restore_mana)
	
	# Restaura stamina
	if item.restore_stamina > 0:
		print("[PLAYER]    💛 +%.0f Stamina (sistema não implementado)" % item.restore_stamina)
	
	# Aplica buff temporário
	if item.apply_buff_duration > 0:
		print("[PLAYER]    ✨ Aplicando buff temporário...")
		apply_consumable_buff(item)
	else:
		print("[PLAYER]    ⚪ Sem buffs")
	
	print("[PLAYER] ═══════════════════════════════════")
	print("[PLAYER] ✅ Consumível aplicado com sucesso!")
	print("[PLAYER] ═══════════════════════════════════\n")


func apply_consumable_buff(item: ItemData) -> void:
	"""Aplica buff temporário de consumível"""
	print("\n[PLAYER] ✨ ═══ INICIANDO BUFF ═══")
	print("[PLAYER]    Duração: %.1fs" % item.apply_buff_duration)
	
	# Armazena velocidade original
	var original_speed = speed
	var original_damage = 0.0
	if current_weapon_data:
		original_damage = current_weapon_data.damage
	
	print("[PLAYER]    Stats ANTES do buff:")
	print("[PLAYER]       Velocidade: %.0f" % original_speed)
	if current_weapon_data:
		print("[PLAYER]       Dano: %.0f" % original_damage)
	
	# Aplica multiplicadores
	var buff_applied = false
	
	if item.buff_speed_multiplier != 1.0:
		speed *= item.buff_speed_multiplier
		print("[PLAYER]    🚀 BUFF DE VELOCIDADE:")
		print("[PLAYER]       Multiplicador: x%.1f" % item.buff_speed_multiplier)
		print("[PLAYER]       Nova velocidade: %.0f" % speed)
		buff_applied = true
	
	if item.buff_damage_multiplier != 1.0:
		# O dano vem da arma equipada, não do player diretamente
		if current_weapon_data:
			current_weapon_data.damage *= item.buff_damage_multiplier
			print("[PLAYER]    ⚔️ BUFF DE DANO:")
			print("[PLAYER]       Multiplicador: x%.1f" % item.buff_damage_multiplier)
			print("[PLAYER]       Novo dano: %.0f" % current_weapon_data.damage)
			buff_applied = true
		else:
			print("[PLAYER]    ⚠️ Buff de dano ignorado: sem arma equipada")
	
	if not buff_applied:
		print("[PLAYER]    ⚠️ Nenhum buff foi aplicado (multiplicadores = 1.0)")
	
	print("[PLAYER] ═══ BUFF ATIVO ═══")
	
	# Aguarda duração do buff
	await get_tree().create_timer(item.apply_buff_duration).timeout
	
	print("\n[PLAYER] ⏱️ ═══ BUFF EXPIROU ═══")
	print("[PLAYER]    Restaurando valores originais...")
	
	# Restaura valores originais
	speed = original_speed
	if item.buff_damage_multiplier != 1.0 and current_weapon_data:
		current_weapon_data.damage = original_damage
	
	print("[PLAYER]    Stats APÓS restauração:")
	print("[PLAYER]       Velocidade: %.0f" % speed)
	if current_weapon_data:
		print("[PLAYER]       Dano: %.0f" % current_weapon_data.damage)
	print("[PLAYER] ═══ BUFF REMOVIDO ═══\n")


# ═════════════════════════════════════════════════════════════
# SISTEMA DE MANA
# ═════════════════════════════════════════════════════════════

## Regenera mana ao longo do tempo
func regenerate_mana(delta: float) -> void:
	if current_mana < max_mana:
		current_mana = min(current_mana + mana_regen_rate * delta, max_mana)
		emit_signal("mana_changed", current_mana)


## Usa mana (retorna true se teve mana suficiente)
func use_mana(amount: float) -> bool:
	if current_mana >= amount:
		current_mana -= amount
		emit_signal("mana_changed", current_mana)
		print("[PLAYER] 🔮 Mana usada: %.1f (Restante: %.1f/%.1f)" % [amount, current_mana, max_mana])
		return true
	else:
		print("[PLAYER] ⚠️ Mana insuficiente! (Atual: %.1f / Necessário: %.1f)" % [current_mana, amount])
		return false


## Define mana atual
func set_mana(amount: float) -> void:
	current_mana = clamp(amount, 0, max_mana)
	emit_signal("mana_changed", current_mana)


## Define mana máxima
func set_max_mana(amount: float) -> void:
	max_mana = amount
	current_mana = min(current_mana, max_mana)
	emit_signal("max_mana_changed", max_mana)
	emit_signal("mana_changed", current_mana)


## Restaura mana completamente
func restore_mana() -> void:
	current_mana = max_mana
	emit_signal("mana_changed", current_mana)
	print("[PLAYER] ✨ Mana restaurada completamente!")


# ========================================
# SISTEMA DE MAGIAS
# ========================================

func setup_spell_system() -> void:
	"""Inicializa o sistema de magias e carrega magias disponíveis"""
	print("\n[PLAYER] 🔮 ═══ INICIANDO SISTEMA DE MAGIAS ═══")
	
	# Carrega as magias disponíveis
	load_available_spells()
	
	# Busca o spell selector UI (pode estar dentro de um CanvasLayer)
	spell_selector_ui = get_node_or_null("SpellSelectorUI")
	
	# Se não encontrou diretamente, tenta dentro do CanvasLayer
	if not spell_selector_ui:
		spell_selector_ui = get_node_or_null("SpellSelectorCanvasLayer/SpellSelectorUI")
	
	print("[PLAYER]    Procurando SpellSelectorUI...")
	
	if spell_selector_ui:
		print("[PLAYER]    ✅ SpellSelectorUI encontrado em: ", spell_selector_ui.get_path())
		
		# Configura as magias no UI
		if not available_spells.is_empty():
			spell_selector_ui.setup_spells(available_spells)
			spell_selector_ui.spell_selected.connect(_on_spell_selected)
			print("[PLAYER] ✅ Spell Selector UI configurado com %d magias" % available_spells.size())
		else:
			print("[PLAYER] ⚠️ Nenhuma magia disponível para configurar")
	else:
		print("[PLAYER] ❌ SpellSelectorUI NÃO ENCONTRADO!")
		print("[PLAYER]    Verifique se o nó existe na cena em:")
		print("[PLAYER]    - Player/SpellSelectorUI")
		print("[PLAYER]    - Player/SpellSelectorCanvasLayer/SpellSelectorUI")
	
	print("[PLAYER] ═══════════════════════════════════\n")


func load_available_spells() -> void:
	"""Carrega as magias disponíveis dos recursos"""
	available_spells.clear()
	
	# Carrega as magias de exemplo
	var fireball = load("res://resources/spells/fireball.tres")
	var ice_bolt = load("res://resources/spells/ice_bolt.tres")
	var heal = load("res://resources/spells/heal.tres")
	var speed_boost = load("res://resources/spells/speed_boost.tres")
	
	if fireball:
		available_spells.append(fireball)
		print("[PLAYER]    🔥 Fireball carregada")
	
	if ice_bolt:
		available_spells.append(ice_bolt)
		print("[PLAYER]    ❄️ Ice Bolt carregada")
	
	if heal:
		available_spells.append(heal)
		print("[PLAYER]    💚 Heal carregada")
	
	if speed_boost:
		available_spells.append(speed_boost)
		print("[PLAYER]    ⚡ Speed Boost carregada")
	
	print("[PLAYER] 📚 Total de magias carregadas: %d" % available_spells.size())


func cast_current_spell() -> void:
	"""Lança a magia atualmente selecionada"""
	if available_spells.is_empty():
		print("[PLAYER] ⚠️ Nenhuma magia disponível!")
		return
	
	var spell = available_spells[current_spell_index]
	
	# Verifica se tem mana suficiente
	if current_mana < spell.mana_cost:
		print("[PLAYER] ❌ Mana insuficiente para lançar %s! (Necessário: %.1f, Atual: %.1f)" % [spell.spell_name, spell.mana_cost, current_mana])
		return
	
	# Consome mana
	print("[PLAYER] 🔮 ANTES de consumir - Mana: %.1f" % current_mana)
	current_mana -= spell.mana_cost
	print("[PLAYER] 🔮 DEPOIS de consumir - Mana: %.1f" % current_mana)
	print("[PLAYER] 🔮 Emitindo sinal mana_changed com valor: %.1f" % current_mana)
	emit_signal("mana_changed", current_mana)
	print("[PLAYER] 🔮 Sinal emitido!")
	
	print("\n[PLAYER] 🔮 ═══ LANÇANDO MAGIA ═══")
	print("[PLAYER]    Nome: %s" % spell.spell_name)
	print("[PLAYER]    Custo: %.1f mana (Restante: %.1f)" % [spell.mana_cost, current_mana])
	print("[PLAYER]    Tipo: %s" % get_spell_type_name(spell.spell_type))
	
	# Lança a magia baseado no tipo
	match spell.spell_type:
		0:  # PROJECTILE
			cast_projectile_spell(spell)
		1:  # AREA
			cast_area_spell(spell)
		2:  # BUFF
			cast_buff_spell(spell)
		4:  # HEAL
			cast_heal_spell(spell)
	
	print("[PLAYER] ═══════════════════════════════════\n")


func cast_projectile_spell(spell: SpellData) -> void:
	"""Lança uma magia de projétil"""
	print("[PLAYER]    🔫 Lançando projétil mágico!")
	print("[PLAYER]    Dano: %.1f" % spell.damage)
	print("[PLAYER]    Velocidade: %.1f" % spell.projectile_speed)
	
	# Carrega a cena do projétil mágico
	var projectile_scene = preload("res://scenes/projectiles/magic_projectile.tscn")
	var projectile = projectile_scene.instantiate()
	
	# Adiciona ao mundo
	get_parent().add_child(projectile)
	
	# Pega a direção do mouse
	var mouse_pos = get_global_mouse_position()
	var spell_direction = (mouse_pos - global_position).normalized()
	
	# Configura o projétil
	projectile.setup(spell, spell_direction, global_position)
	
	print("[PLAYER]    ✅ Projétil criado e lançado!")


func cast_area_spell(spell: SpellData) -> void:
	"""Lança uma magia de área"""
	print("[PLAYER]    💥 Lançando magia de área!")
	print("[PLAYER]    Dano: %.1f" % spell.damage)
	print("[PLAYER]    Raio: %.1f" % spell.area_radius)
	
	# Carrega a cena da área mágica
	var area_scene = preload("res://scenes/spells/magic_area.tscn")
	var area = area_scene.instantiate()
	
	# Adiciona ao mundo
	get_parent().add_child(area)
	
	# Posiciona na posição do mouse ou do jogador
	var spawn_pos = get_global_mouse_position() if spell.requires_target else global_position
	
	# Configura a área
	area.setup(spell, spawn_pos)
	
	print("[PLAYER]    ✅ Área mágica criada!")


func cast_buff_spell(spell: SpellData) -> void:
	"""Lança uma magia de buff"""
	print("[PLAYER]    ✨ Aplicando buff!")
	print("[PLAYER]    Duração: %.1fs" % spell.duration)
	print("[PLAYER]    Speed: %.2fx | Damage: %.2fx | Defense: %.2fx" % [spell.speed_modifier, spell.damage_modifier, spell.defense_modifier])
	
	# Salva os valores originais se ainda não estão salvos
	if not has_meta("original_speed"):
		set_meta("original_speed", speed)
	if not has_meta("original_damage_multiplier"):
		set_meta("original_damage_multiplier", 1.0)
	
	# Aplica os modificadores
	speed *= spell.speed_modifier
	var damage_multiplier = get_meta("original_damage_multiplier", 1.0) * spell.damage_modifier
	set_meta("current_damage_multiplier", damage_multiplier)
	
	print("[PLAYER]    Nova velocidade: %.1f" % speed)
	
	# Remove o buff após a duração
	await get_tree().create_timer(spell.duration).timeout
	
	# Restaura valores originais
	speed = get_meta("original_speed")
	set_meta("current_damage_multiplier", get_meta("original_damage_multiplier"))
	
	print("[PLAYER]    ⏰ Buff expirou! Valores restaurados.")


func cast_heal_spell(spell: SpellData) -> void:
	"""Lança uma magia de cura"""
	var heal_amount = spell.heal_amount
	var old_health = current_health
	current_health = min(current_health + heal_amount, max_health)
	var actual_heal = current_health - old_health
	emit_signal("health_changed", current_health)
	
	print("[PLAYER]    💚 Cura aplicada: +%.1f HP" % actual_heal)
	print("[PLAYER]    HP: %.1f/%.1f" % [current_health, max_health])
	
	# TODO: Adicionar efeito visual de cura
	# if spell.cast_particle:
	#     spawn_heal_effect()



func get_spell_type_name(type: int) -> String:
	"""Retorna o nome do tipo de magia"""
	match type:
		0: return "PROJECTILE"
		1: return "AREA"
		2: return "BUFF"
		3: return "HEAL"
		_: return "UNKNOWN"


func select_next_spell() -> void:
	"""Seleciona a próxima magia (tecla E)"""
	if spell_selector_ui:
		spell_selector_ui.select_next_spell()


func select_previous_spell() -> void:
	"""Seleciona a magia anterior (tecla Q)"""
	if spell_selector_ui:
		spell_selector_ui.select_previous_spell()


func _on_spell_selected(spell: Resource) -> void:
	"""Callback quando uma magia é selecionada"""
	for i in range(available_spells.size()):
		if available_spells[i] == spell:
			current_spell_index = i
			break
	
	print("[PLAYER] 🎯 Magia selecionada: %s" % spell.spell_name)
