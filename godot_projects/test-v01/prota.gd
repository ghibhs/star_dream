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

@export var projectile_scene: PackedScene # Arraste sua cena Projectile.tscn aqui no editor!
@export var shoot_cooldown: float = 0.5 # Tempo entre os disparos

var can_shoot: bool = true
var shoot_timer: Timer

func _ready():
	shoot_timer = Timer.new()
	add_child(shoot_timer)
	shoot_timer.timeout.connect(func(): can_shoot = true)
	shoot_timer.one_shot = true # O timer só roda uma vez
	
	# Exemplo de configuração de rotação da arma para seguir o mouse
	# Se sua arma é um filho do jogador e você quer que ela aponte para o mouse
	# ajuste este código de acordo com sua hierarquia.
	if get_parent() and get_parent().has_method("get_global_mouse_position"): # Assumindo que o jogador tem este método
		pass # A rotação para o mouse será feita em _process ou _physics_process

func _process(delta: float):
	# Exemplo de rotação da arma para apontar para o mouse
	# Se a sua arma for um filho do seu personagem, e você quiser que a arma siga o mouse
	# este código pode ser colocado no script da arma.
	# Certifique-se de que o "offset" do seu sprite da arma está no ponto de pivô correto.
	# A rotação deve ser baseada na posição global da arma.
	look_at(get_global_mouse_position())

	if Input.is_action_just_pressed("shoot") and can_shoot:
		shoot()
		can_shoot = false
		shoot_timer.start(shoot_cooldown)

func shoot():
	if projectile_scene:
		var projectile_instance = projectile_scene.instantiate()
		
		# Define a posição de onde o projétil vai nascer.
		# Isso pode ser um Node2D vazio (Marker2D) na sua cena que representa a ponta da arma.
		# Exemplo: Se você tem um Node2D chamado "Muzzle" como filho da sua arma:
		# projectile_instance.global_position = $Muzzle.global_position
		
		# Por simplicidade, vamos usar a posição global da própria arma/jogador
		projectile_instance.global_position = global_position
		
		# Define a direção do projétil.
		# Se a arma está apontando para o mouse, a direção é a direção do "forward" da arma.
		# Para 2D, isso é o vetor para onde o "right" do nó está apontando.
		var shoot_direction = (get_global_mouse_position() - global_position).normalized()
		projectile_instance.set_direction(shoot_direction)
		
		# Adiciona o projétil ao nó pai (geralmente o nó principal da cena, como "World" ou "Game")
		get_parent().add_child(projectile_instance)
	else:
		push_warning("Projectile scene not assigned!")
