# CollectableItem.gd (area_2d.gd)
extends Area2D

@export var item_data: Weapon_Data : set = set_item_data
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if item_data:
		setup_item()

func set_item_data(new_data: Weapon_Data) -> void:
	item_data = new_data
	if animated_sprite and collision:
		setup_item()

func setup_item() -> void:
	if not item_data:
		return
	if animated_sprite:
		animated_sprite.sprite_frames = item_data.sprite_frames
		if item_data.animation_name != "":
			animated_sprite.animation = item_data.animation_name
		animated_sprite.play()
	if collision and item_data.collision_shape:
		collision.shape = item_data.collision_shape

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("receive_weapon_data"):
		body.call_deferred("receive_weapon_data", item_data)
		queue_free()
