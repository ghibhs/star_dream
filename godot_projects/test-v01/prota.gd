extends CharacterBody2D

# Define a velocidade do jogador.
@export var speed = 200

# Esta função é chamada a cada frame.
func _physics_process(delta):
	# Obtém a entrada do jogador (teclas de seta ou WASD).
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# Define a velocidade com base na direção e na velocidade.
	velocity = direction * speed

	# Move o personagem.
	move_and_slide()
