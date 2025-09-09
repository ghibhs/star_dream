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
var current_speed = speed

@onready var animated_sprite = $AnimatedSprite2D

var current_direction: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2(1, 0)

func _physics_process(delta):
	# Captura input de movimento em 8 direções
	var input_vector = get_8_direction_input()
	
	# Aplica velocidade
	if input_vector != Vector2.ZERO:
		velocity = input_vector * speed
		update_sprite_direction(input_vector, true)
	else:
		velocity = Vector2.ZERO
		update_sprite_direction(Vector2.ZERO, false)
	
	# Move o personagem
	if Input.is_action_pressed("sprint"):
		current_speed *= sprint_multiplier
		
	# Aplica o movimento
	velocity = input_vector * current_speed
	move_and_slide()
	
func update_sprite_direction(direction_vector: Vector2, is_moving: bool = false):
	var new_direction = get_8_direction_input()
	
	# Só atualiza se a direção mudou
	if new_direction != current_direction:
		current_direction = new_direction
		
		if is_moving:
			last_direction = new_direction
			play_walk_animation(new_direction)

func get_8_direction_input() -> Vector2:
	# Captura input das teclas direcionais
	var left = Input.is_action_pressed("ui_left")
	var right = Input.is_action_pressed("ui_right") 
	var up = Input.is_action_pressed("ui_up")
	var down = Input.is_action_pressed("ui_down")
	
	# Determina vetor de movimento baseado nas combinações de teclas
	var direction = Vector2.ZERO
	
	# Movimento nas 8 direções
	if up and right:
		direction = Vector2(0.707, -0.707)  # Diagonal superior direita
	elif down and right:
		direction = Vector2(0.707, 0.707)   # Diagonal inferior direita
	elif down and left:
		direction = Vector2(-0.707, 0.707)  # Diagonal inferior esquerda
	elif up and left:
		direction = Vector2(-0.707, -0.707) # Diagonal superior esquerda
	elif right:
		direction = Vector2(1, 0)           # Direita
	elif left:
		direction = Vector2(-1, 0)          # Esquerda
	elif up:
		direction = Vector2(0, -1)          # Cima
	elif down:
		direction = Vector2(0, 1)           # Baixo
	
	return direction

func play_walk_animation(direction: Vector2):
	var animation_name = vector_to_animation_name(direction)
	
	if animation_name != "":
		animated_sprite.play(animation_name)
	else:
		print("Nenhuma animação de walk encontrada para a direção: ", direction)
		
func vector_to_animation_name(direction: Vector2) -> String:
	var vector_string = str(direction)
	vector_string = vector_string.replace("(", "").replace(")", "").replace(", ", "_")
	
	if animated_sprite.sprite_frames.has_animation(vector_string):
		return vector_string
	else:
		print("Animação não encontrada: " + vector_string)
		return ""
