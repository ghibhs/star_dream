extends Node2D

@onready var bow_scene: PackedScene = preload("res://art/bow.tscn")

func _ready():
	var bow = bow_scene.instantiate()
	add_child(bow)
	bow.position = Vector2(20, 20)
	
