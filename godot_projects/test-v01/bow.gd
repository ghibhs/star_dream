extends Node2D

@export var arrow_scene: PackedScene
@export var max_power: float = 1000.0
@export var min_power: float = 200.0

signal arrow_shot

var is_charging = false
var charge_time = 0.0
var arrow_spawn_point: Marker2D

func _ready():
	arrow_spawn_point = $ArrowSpawnPoint
	
	# Carrega a cena da flecha se não foi definida no editor
	if not arrow_scene:
		arrow_scene = preload("res://projectile.tscn")

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_charging()
			else:
				shoot_arrow()
	
	if event is InputEventMouseMotion:
		aim_at_mouse()

func start_charging():
	is_charging = true
	charge_time = 0.0

func _process(delta):
	if is_charging:
		charge_time += delta
		# Rotaciona o arco baseado na posição do mouse
		aim_at_mouse()

func aim_at_mouse():
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()
	rotation = direction.angle()

func shoot_arrow():
	if not is_charging:
		return
		
	is_charging = false
	
	# Calcula a força baseada no tempo de carregamento
	var power = min_power + (charge_time * max_power)
	power = min(power, max_power)
	
	# Cria e configura a flecha
	var arrow = arrow_scene.instantiate()
	get_tree().current_scene.add_child(arrow)
	
	arrow.global_position = arrow_spawn_point.global_position
	arrow.rotation = rotation
	
	# Define velocidade da flecha
	var direction = Vector2.RIGHT.rotated(rotation)
	arrow.shoot(direction * power)
	
	emit_signal("arrow_shot")
	
	charge_time = 0.0

func get_charge_percentage() -> float:
	if not is_charging:
		return 0.0
	
	return min(charge_time * max_power, max_power) / max_power
