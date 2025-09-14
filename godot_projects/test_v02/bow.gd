extends Area2D

var arrow_scene = preload("res://arrow.tscn")
@onready var timer = $Timer
@onready var anim = $AnimatedSprite2D
signal bow_collected(value)

func _physics_process(delta: float) -> void:
	if timer.is_stopped():
		shooting()
	
func shooting():
	if Input.is_action_pressed("shoot"):
		anim.play("conclick")
		shoot()
		print('pressed')
		
		
func shoot():
	var arrow_instance = arrow_scene.instantiate()
	add_child(arrow_instance)
	print("shooted")
	timer.start()

func _ready():
	add_to_group("items") # Adiciona ao grupo
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	bow_collected.emit("res://bow.tscn")
	queue_free()
	
