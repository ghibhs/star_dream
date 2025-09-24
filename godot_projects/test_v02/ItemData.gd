# ItemData.gd
class_name ItemData
extends Resource

@export var sprite_frames: SpriteFrames  # ← Mudança aqui
@export var animation_name: String = "default"
@export var collision_shape: Shape2D
@export var item_name: String
@export var value: int
@export var sound_effect: AudioStream
