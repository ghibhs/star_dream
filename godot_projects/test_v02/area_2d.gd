# CollectableItem.gd (area_2d.gd)
extends Area2D

@export var item_data: ItemData : set = set_item_data
@onready var animated_sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D

func set_item_data(new_data: ItemData):
	item_data = new_data
	if animated_sprite and collision:
		setup_item()

func _ready():
	if item_data:
		setup_item()

func setup_item():
	if item_data:
		if item_data.sprite_frames:
			animated_sprite.sprite_frames = item_data.sprite_frames
			if item_data.animation_name and item_data.animation_name != "":
				animated_sprite.play(item_data.animation_name)
			else:
				animated_sprite.play()
		
		if item_data.collision_shape:
			collision.shape = item_data.collision_shape




func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	pass # Replace with function body.
