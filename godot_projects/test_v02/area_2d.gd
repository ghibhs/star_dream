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
	if item_data:
		setup_item()
	
	# Conecta o sinal de colisão
	body_entered.connect(_on_body_entered)

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
	if body.is_in_group("player"):
		# Usa call_deferred para enviar os dados
		body.call_deferred("receive_weapon_data", item_data)
		# Remove o item
		queue_free()
