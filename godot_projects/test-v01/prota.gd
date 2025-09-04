extends CharacterBody2D

@export var speed: float = 300.0  # Velocidade base do personagem
@export var sprint_multiplier: float = 1.5
@export var dash_speed: float = 1000.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 1.0

var can_dash: bool = true
var is_dashing: bool = false
var dash_timer: float = 0.0
var cooldown_timer: float = 0.0

func _physics_process(delta: float) -> void:
	# Pega o input de movimento
	var input_direction = Vector2.ZERO
	
	# Movimento horizontal
	if Input.is_action_pressed("ui_right"):
		input_direction.x += 1
	if Input.is_action_pressed("ui_left"):
		input_direction.x -= 1
	
	# Movimento vertical
	if Input.is_action_pressed("ui_down"):
		input_direction.y += 1
	if Input.is_action_pressed("ui_up"):
		input_direction.y -= 1
	
	if input_direction.length() > 0:
		input_direction = input_direction.normalized()
	
	# Verifica se está correndo (você precisa configurar a ação "sprint" no Project Settings)
	var current_speed = speed
	if Input.is_action_pressed("sprint"):
		current_speed *= sprint_multiplier
		
	
	
	# Aplica o movimento
	velocity = input_direction * current_speed
	move_and_slide()
	
	update_animation(input_direction)

func update_animation(direction: Vector2) -> void:
	if not direction:
		# Personagem parado
		play_animation("idle")
		return
	
	# Determina a direção da animação
	var angle = direction.angle()
	
	# Converte o ângulo em direções de animação
	if angle < -2.748: # Entre -157.5° e 180°
		play_animation("left")
	elif angle < -1.963: # Entre -157.5° e -112.5°
		play_animation("up_left")
	elif angle < -1.178: # Entre -112.5° e -67.5°
		play_animation("up")
	elif angle < -0.393: # Entre -67.5° e -22.5°
		play_animation("up_right")
	elif angle < 0.393: # Entre -22.5° e 22.5°
		play_animation("right")
	elif angle < 1.178: # Entre 22.5° e 67.5°
		play_animation("down_right")
	elif angle < 1.963: # Entre 67.5° e 112.5°
		play_animation("down")
	elif angle < 2.748: # Entre 112.5° e 157.5°
		play_animation("down_left")
	else: # Entre 157.5° e 180°
		play_animation("left")

func play_animation(anim_name: String) -> void:
	if $AnimatedSprite2D:  # Se você tiver um AnimatedSprite2D
		$AnimatedSprite2D.play(anim_name)
		
