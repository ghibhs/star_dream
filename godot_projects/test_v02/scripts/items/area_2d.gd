# CollectableItem.gd (area_2d.gd)
extends Area2D

@export var item_data: WeaponData : set = set_item_data
@onready var animated_sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D

# Previne coletar imediatamente após dropar
var can_be_picked_up: bool = true
var pickup_delay: float = 0.5  # Meio segundo de delay
var is_dropped_item: bool = false  # Flag para saber se é item dropado

func set_item_data(new_data: WeaponData):
	item_data = new_data
	# Se já estamos na árvore e os nodes estão prontos, configura imediatamente
	if is_inside_tree() and animated_sprite and collision:
		setup_item()
	# Se ainda não estamos na árvore, esconde o sprite até estar pronto
	elif animated_sprite:
		animated_sprite.visible = false

func _ready():
	print("[ITEM] Item inicializado: ", name)
	print("[ITEM]    Collision Layer: ", collision_layer, " (binário: ", String.num_int64(collision_layer, 2), ")")
	print("[ITEM]    Collision Mask: ", collision_mask, " (binário: ", String.num_int64(collision_mask, 2), ")")
	
	# Esconde temporariamente até configurar (evita glitch visual)
	if animated_sprite:
		animated_sprite.visible = false
		print("[ITEM]    Sprite escondido até configuração")
	
	if item_data:
		setup_item()
		print("[ITEM]    Item Data: ", item_data.resource_path)
	else:
		print("[ITEM]    ⚠️ AVISO: Nenhum item_data configurado!")
	
	# Se é um item dropado, aplica delay antes de permitir coleta
	if is_dropped_item:
		can_be_picked_up = false
		print("[ITEM]    ⏳ Item dropado, aguardando ", pickup_delay, "s antes de permitir coleta...")
		await get_tree().create_timer(pickup_delay).timeout
		can_be_picked_up = true
		print("[ITEM]    ✅ Item agora pode ser coletado")
	
	# Conecta o sinal de colisão (verifica se já não está conectado)
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
		print("[ITEM]    Signal body_entered conectado")
	else:
		print("[ITEM]    Signal body_entered já estava conectado")

func setup_item():
	if item_data:
		print("[ITEM] ⚙️ Configurando item: ", item_data.item_name)
		
		if item_data.sprite_frames:
			animated_sprite.sprite_frames = item_data.sprite_frames
			if item_data.animation_name != "":
				animated_sprite.play(item_data.animation_name)
			else:
				animated_sprite.play()
			print("[ITEM]    Sprite configurado: ", item_data.animation_name)
		
		# ⚠️ IMPORTANTE: Configura a ESCALA do sprite do item
		if "Sprite_scale" in item_data and item_data.Sprite_scale != Vector2.ZERO:
			animated_sprite.scale = item_data.Sprite_scale
			print("[ITEM]    Escala configurada: ", item_data.Sprite_scale)
		else:
			# Se não tiver escala definida, usa padrão
			animated_sprite.scale = Vector2.ONE
			print("[ITEM]    Escala padrão: (1, 1)")
		
		# ⚠️ IMPORTANTE: Configura a POSIÇÃO do sprite se definida
		if "sprite_position" in item_data and item_data.sprite_position != Vector2.ZERO:
			animated_sprite.position = item_data.sprite_position
			print("[ITEM]    Posição do sprite: ", item_data.sprite_position)
		
		if item_data.collision_shape:
			collision.shape = item_data.collision_shape
			print("[ITEM]    Collision shape configurado")
		
		# Torna o sprite visível DEPOIS de configurar tudo (evita glitch)
		animated_sprite.visible = true
		
		print("[ITEM]    ✅ Item configurado com sucesso")


func initialize_dropped_item(weapon_data: WeaponData) -> void:
	"""
	Função específica para configurar item dropado.
	Deve ser chamada ANTES de adicionar o item à árvore.
	"""
	print("[ITEM] 📦 Inicializando item dropado")
	item_data = weapon_data
	is_dropped_item = true  # Marca como item dropado
	
	# Força configuração imediata dos nodes filhos (mesmo antes de _ready)
	# Pegamos os nodes diretamente em vez de usar @onready
	animated_sprite = get_node_or_null("AnimatedSprite2D")
	collision = get_node_or_null("CollisionShape2D")
	
	if animated_sprite and collision and item_data:
		# Esconde antes de configurar
		animated_sprite.visible = false
		setup_item()
	else:
		push_error("[ITEM] ❌ Falha ao obter nodes para configuração!")

func _on_body_entered(body):
	print("[ITEM] 🎯 Colisão detectada!")
	print("[ITEM]    Body: ", body.name)
	print("[ITEM]    Body tipo: ", body.get_class())
	print("[ITEM]    Está no grupo 'player'? ", body.is_in_group("player"))
	print("[ITEM]    Pode ser coletado? ", can_be_picked_up)
	
	if body.is_in_group("player") and can_be_picked_up:
		print("[ITEM] ✅ Player detectado! Enviando item_data...")
		if item_data:
			print("[ITEM]    Item: ", item_data.item_name)
			print("[ITEM]    Escala do item: ", item_data.Sprite_scale)
		# Usa call_deferred para enviar os dados
		body.call_deferred("receive_weapon_data", item_data)
		print("[ITEM]    Item sendo removido...")
		# Remove o item
		queue_free()
	elif not can_be_picked_up:
		print("[ITEM]    ⏳ Item em cooldown de coleta, aguarde...")
	else:
		print("[ITEM]    ⚠️ Body não está no grupo 'player', ignorando")
