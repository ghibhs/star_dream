# ItemData.gd
class_name ItemData  # ← MUITO IMPORTANTE!
extends Resource

@export var sprite_texture: Texture2D
@export var collision_shape: Shape2D
@export var item_name: String
@export var damage: float
@export var speed: float
@export var sound_effect: AudioStream
