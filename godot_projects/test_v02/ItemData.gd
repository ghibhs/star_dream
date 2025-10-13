# ItemData.gd
class_name ItemData
extends Resource

# Dados visuais do item coletável
@export var sprite_frames: SpriteFrames
@export var animation_name: String = "default"
@export var collision_shape: Shape2D  # Para coleta do item
@export var item_name: String
@export var value: int

# Efeitos
@export var sound_effect: AudioStream
@export var hit_effect: PackedScene
