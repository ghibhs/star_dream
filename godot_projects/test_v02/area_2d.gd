extends Area2D

@export var item_data: ItemData  # Arraste o recurso aqui no inspetor
@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

func _ready():
	if item_data:
		setup_item()

func setup_item():
	sprite.texture = item_data.sprite_texture
	collision.shape = item_data.collision_shape
	name = item_data.item_name
