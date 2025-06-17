extends Node2D

@export var speed: float = 500.0
@export var damage: int = 10

var direction: Vector2 = Vector2.RIGHT # A direção padrão, será definida pela arma

func _ready():
	# Conecta o sinal body_entered para detectar colisões
	# Conecta o sinal screen_exited para destruir o projétil quando sair da tela
	# Se você não tiver VisibleOnScreenNotifier2D, remova essa linha e a função _on_screen_exited
	if get_node_or_null("VisibleOnScreenNotifier2D"):
		get_node("VisibleOnScreenNotifier2D").screen_exited.connect(_on_screen_exited)

func _physics_process(delta: float):
	# Move o projétil na direção definida
	position += direction * speed * delta

func _on_body_entered(body: Node2D):
	# Exemplo simples: imprimir o nome do corpo que colidiu
	print("Projetil colidiu com: ", body.name)

	# Exemplo mais complexo: se o corpo tiver um método 'take_damage', chame-o
	if body.has_method("take_damage"):
		body.take_damage(damage)

	# Destrói o projétil após a colisão
	queue_free()

func _on_screen_exited():
	# Destrói o projétil quando ele sai da tela para evitar vazamento de memória
	queue_free()

func set_direction(dir: Vector2):
	direction = dir.normalized() # Garante que a direção seja um vetor unitário
	# Opcional: Rotacionar o sprite do projétil para apontar na direção do movimento
	rotation = direction.angle()
