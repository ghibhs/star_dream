# spell_impact_area.gd
extends Area2D
class_name SpellImpactArea

## Área de efeito que aparece quando um projétil acerta
## Causa dano em área e mostra sprite de impacto

var damage: float = 10.0
var duration: float = 0.5
var radius: float = 50.0
var affected_enemies: Array = []  # Inimigos já atingidos (evita dano múltiplo)

var sprite: AnimatedSprite2D
var collision_shape: CollisionShape2D
var timer: Timer


func _ready() -> void:
	# Cria sprite animado
	sprite = AnimatedSprite2D.new()
	add_child(sprite)
	sprite.z_index = 1  # Acima de outros sprites
	
	# Cria colisão circular
	collision_shape = CollisionShape2D.new()
	add_child(collision_shape)
	var circle = CircleShape2D.new()
	circle.radius = radius
	collision_shape.shape = circle
	
	# Configuração da Area2D
	collision_layer = 0
	collision_mask = 4  # Layer de inimigos
	
	# Conecta sinais
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	
	# Timer para destruir após duração (será configurado no setup)
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(_on_timeout)
	# NÃO inicia aqui - será iniciado no setup() se necessário
	
	print("[IMPACT_AREA] 💥 Área de impacto criada - Raio: %.0f, Dano: %.1f" % [radius, damage])


func setup(impact_damage: float, impact_radius: float, impact_duration: float, 
		   sprite_frames: SpriteFrames, animation_name: String = "default") -> void:
	"""Configura a área de impacto"""
	damage = impact_damage
	radius = impact_radius
	duration = impact_duration
	
	# Configura sprite se fornecido
	if sprite_frames:
		sprite.sprite_frames = sprite_frames
		if animation_name != "":
			sprite.play(animation_name)
		else:
			sprite.play()
		
		# Conecta sinal de fim de animação para sincronizar destruição
		sprite.animation_finished.connect(_on_animation_finished)
		
		print("[IMPACT_AREA] 🎨 Sprite configurado: %s" % animation_name)
	
	# Atualiza raio da colisão se já foi criada
	if collision_shape and collision_shape.shape:
		collision_shape.shape.radius = radius
	
	# Inicia timer apenas se duração é razoável (< 100s = não é persistente)
	if duration < 100.0 and timer:
		timer.start(duration)
		print("[IMPACT_AREA] ⏱️ Timer iniciado: %.1fs" % duration)
	else:
		print("[IMPACT_AREA] ♾️ Área persistente (sem timer)")
	
	print("[IMPACT_AREA] ⚡ Área configurada - Dano: %.1f, Raio: %.0fpx, Duração: %.1fs" % 
		[damage, radius, duration])


func _on_body_entered(body: Node2D) -> void:
	"""Quando um corpo entra na área"""
	if not body.is_in_group("enemies"):
		return
	
	# Se já atingiu esse inimigo, ignora
	if affected_enemies.has(body):
		return
	
	print("[IMPACT_AREA]    💥 Atingiu inimigo: %s" % body.name)
	
	# Aplica dano usando call_deferred para evitar erro de state change durante query
	if body.has_method("take_damage"):
		affected_enemies.append(body)
		body.call_deferred("take_damage", damage, false)
		print("[IMPACT_AREA]    ⚔️ Dano aplicado: %.1f" % damage)


func _on_area_entered(area: Area2D) -> void:
	"""Quando uma área entra (alguns inimigos podem usar Area2D)"""
	var body = area.get_parent()
	if body and body.is_in_group("enemies"):
		_on_body_entered(body)


func _on_timeout() -> void:
	"""Quando o timer termina"""
	print("[IMPACT_AREA]    ⏱️ Duração expirada, removendo área")
	queue_free()


func _on_animation_finished() -> void:
	"""Quando a animação termina, pode destruir antes do timer"""
	# Opcionalmente, destruir quando animação termina ao invés de esperar timer
	# Descomente a linha abaixo se quiser que a área suma quando a animação acabar
	# queue_free()
	pass
