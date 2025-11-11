extends Node2D

# ===== MÚSICA =====
var game_music: AudioStreamPlayer = null

# ===== BOSS SPAWNER =====
@export var boss_scene: PackedScene = preload("res://scenes/enemy/boss.tscn")
@export var boss_data: Resource = preload("res://resources/enemies/boss_wolf.tres")
@export var boss_spawn_time: float = 60.0  # 1 minuto
var boss_timer: Timer = null
var boss_spawned: bool = false


func _ready() -> void:
	print("[THE_GAME] 🎮 Cena do jogo carregada")
	
	# Configura e toca música do jogo
	setup_game_music()
	
	# Configura timer do boss
	setup_boss_timer()
	
	# Inicia o contador de tempo e estatísticas
	if has_node("/root/GameStats"):
		get_node("/root/GameStats").start_game()
		print("[THE_GAME] ✅ Sistema de estatísticas iniciado")
	else:
		push_error("[THE_GAME] ❌ GameStats autoload não encontrado!")


func _exit_tree() -> void:
	# Para a música
	if game_music and is_instance_valid(game_music):
		game_music.stop()
		print("[THE_GAME] 🎵 Música do jogo parada")
	
	# Para o contador quando sair da cena
	if has_node("/root/GameStats"):
		get_node("/root/GameStats").stop_game()
		print("[THE_GAME] ⏹️ Sistema de estatísticas pausado")


func setup_game_music() -> void:
	"""Configura e toca a música do jogo (Jornada Sem Fim)"""
	game_music = AudioStreamPlayer.new()
	add_child(game_music)
	
	# Carrega a música "Jornada Sem Fim"
	var music_path = "res://Music/Jornada Sem Fim.mp3"
	if ResourceLoader.exists(music_path):
		game_music.stream = load(music_path)
		game_music.volume_db = -8.0  # Volume mais baixo para não atrapalhar os efeitos sonoros
		game_music.autoplay = false
		game_music.bus = "Music"  # Usa o bus de música (se existir)
		game_music.play()
		print("[THE_GAME] 🎵 Música 'Jornada Sem Fim' iniciada")
	else:
		print("[THE_GAME] ⚠️ Música não encontrada: ", music_path)


func setup_boss_timer() -> void:
	"""Configura timer para spawnar o boss após 1 minuto"""
	boss_timer = Timer.new()
	boss_timer.wait_time = boss_spawn_time
	boss_timer.one_shot = true
	boss_timer.timeout.connect(_on_boss_timer_timeout)
	add_child(boss_timer)
	boss_timer.start()
	print("[THE_GAME] ⏰ Timer do boss iniciado: %.0fs até spawn" % boss_spawn_time)


func _on_boss_timer_timeout() -> void:
	"""Spawna o boss quando o timer terminar"""
	if boss_spawned:
		return
	
	spawn_boss()


func spawn_boss() -> void:
	"""Spawna o boss na cena"""
	if not boss_scene or not boss_data:
		push_error("[THE_GAME] ❌ Boss scene ou data não configurado!")
		return
	
	var boss_instance = boss_scene.instantiate()
	boss_instance.boss_data = boss_data
	
	# Spawna o boss em uma posição aleatória longe do player
	var player = get_node_or_null("Player")
	var spawn_pos = Vector2.ZERO
	
	if player:
		var distance = 400.0  # Distância do player
		var angle = randf() * TAU  # Ângulo aleatório
		spawn_pos = player.global_position + Vector2.RIGHT.rotated(angle) * distance
	else:
		spawn_pos = Vector2(300, -100)  # Posição padrão
	
	boss_instance.global_position = spawn_pos
	add_child(boss_instance)
	boss_spawned = true
	
	print("[THE_GAME] 🐺 BOSS SPAWNOU em ", spawn_pos)
