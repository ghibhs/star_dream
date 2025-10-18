# Projectile.gd
extends Area2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
@onready var screen_notifier = $VisibleOnScreenNotifier2D
@export var angle_offset_deg: float = 0.0

var direction: Vector2
var speed: float
var damage: float
var pierce: bool = false


func _ready():
	print("[PROJECTILE] Inicializado")
	body_entered.connect(_on_body_entered)
	if screen_notifier:
		screen_notifier.screen_exited.connect(queue_free)

func setup_from_weapon_data(weapon_data: Weapon_Data, dir: Vector2):
	print("[PROJECTILE] Configurando projétil...")
	print("[PROJECTILE]    Arma: ", weapon_data.item_name)
	print("[PROJECTILE]    Direção: ", dir)
	
	# Configura visual
	animated_sprite.sprite_frames = weapon_data.projectile_sprite_frames
	animated_sprite.play(weapon_data.projectile_name)
	animated_sprite.scale = weapon_data.projectile_scale
	print("[PROJECTILE]    Sprite configurado (animação: ", weapon_data.projectile_name, ")")
	
	# Configura collision
	collision.shape = weapon_data.projectile_collision
	print("[PROJECTILE]    CollisionShape configurado")
	
	# Configura movimento
	direction = dir.normalized()
	
	var ang : float = direction.angle() + deg_to_rad(angle_offset_deg)
	rotation = ang       # <- gira o Area2D (sprite + colisão juntos)
	
	speed = weapon_data.projectile_speed
	damage = weapon_data.damage
	pierce = weapon_data.pierce
	
	print("[PROJECTILE]    Velocidade: %.1f | Dano: %.1f | Pierce: %s" % [speed, damage, pierce])
	print("[PROJECTILE]    ✅ Configuração completa!")
	

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	print("[PROJECTILE] 💥 Colidiu com: ", body.name)
	print("[PROJECTILE]    Grupos: ", body.get_groups())
	
	if body.is_in_group("enemies"):
		print("[PROJECTILE]    ✅ É um inimigo!")
		if body.has_method("take_damage"):
			print("[PROJECTILE]    💥 Causando %.1f de dano" % damage)
			body.take_damage(damage)
			print("[PROJECTILE]    ✅ Dano aplicado")
		else:
			print("[PROJECTILE]    ⚠️ Inimigo não tem método take_damage()")
		
		if not pierce:
			print("[PROJECTILE]    🗑️ Projétil sem pierce, destruindo...")
			queue_free()
		else:
			print("[PROJECTILE]    ➡️ Projétil tem pierce, continuando...")
	elif body.is_in_group("walls"):
		print("[PROJECTILE]    🧱 Colidiu com parede")
		print("[PROJECTILE]    🗑️ Destruindo projétil...")
		queue_free()
