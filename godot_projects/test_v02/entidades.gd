extends CharacterBody2D

@export var speed: float = 100.0
@export var direction: Vector2 = Vector2.ZERO
@onready var animation = $AnimatedSprite2D

func _physics_process(_delta: float) -> void:
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if direction != Vector2.ZERO:
		play_animations(direction)
	else:
		animation.stop()
		
	velocity = direction * speed
	move_and_slide()

func play_animations(dir: Vector2):
	
	if dir.x > 0 and dir.y == 0:
		animation.play("default")
	if dir.x < 0 and dir.y == 0:
		animation.play("new_animation_3")
	if dir.x == 0 and dir.y < 0:
		animation.play("new_animation_1")
	if dir.x == 0 and dir.y > 0:
		animation.play("new_animation_5")
	if dir.x > 0 and dir.y < 0:
		animation.play("new_animation")
	if dir.x < 0 and dir.y < 0:
		animation.play("new_animation_2")
	if dir.x < 0 and dir.y > 0:
		animation.play("new_animation_4")
	if dir.x > 0 and dir.y > 0:
		animation.play("new_animation_6")
		
func _ready():
	# OPÇÃO A: Conectar a um arco específico por referênci
	call_deferred("setup_connections")
