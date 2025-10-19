# CollectableItem.gd (area_2d.gd)
extends Area2D

@export var item_data: Weapon_Data : set = set_item_data
@onready var animated_sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D

func set_item_data(new_data: Weapon_Data):
	item_data = new_data
	if animated_sprite and collision:
		setup_item()

func _ready():
	print("[ITEM] Item inicializado: ", name)
	print("[ITEM]    Collision Layer: ", collision_layer, " (binário: ", String.num_int64(collision_layer, 2), ")")
	print("[ITEM]    Collision Mask: ", collision_mask, " (binário: ", String.num_int64(collision_mask, 2), ")")
	
	if item_data:
		setup_item()
		print("[ITEM]    Item Data: ", item_data.resource_path)
	else:
		print("[ITEM]    ⚠️ AVISO: Nenhum item_data configurado!")
	
	# Conecta o sinal de colisão
	body_entered.connect(_on_body_entered)
	print("[ITEM]    Signal body_entered conectado")

func setup_item():
	if item_data:
		if item_data.sprite_frames:
			animated_sprite.sprite_frames = item_data.sprite_frames
			if item_data.animation_name != "":
				animated_sprite.play(item_data.animation_name)
			else:
				animated_sprite.play()
		
		if item_data.collision_shape:
			collision.shape = item_data.collision_shape

func _on_body_entered(body):
	print("[ITEM] 🎯 Colisão detectada!")
	print("[ITEM]    Body: ", body.name)
	print("[ITEM]    Body tipo: ", body.get_class())
	print("[ITEM]    Está no grupo 'player'? ", body.is_in_group("player"))
	
	if body.is_in_group("player"):
		print("[ITEM] ✅ Player detectado! Enviando item_data...")
		# Usa call_deferred para enviar os dados
		body.call_deferred("receive_weapon_data", item_data)
		print("[ITEM]    Item sendo removido...")
		# Remove o item
		queue_free()
	else:
		print("[ITEM]    ⚠️ Body não está no grupo 'player', ignorando")
