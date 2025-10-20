# enemy_spawner.gd
extends Node2D

# ===== CONFIGURAÇÕES DE SPAWN =====
@export var spawn_enabled: bool = true
@export var spawn_interval: float = 3.0  # Segundos entre spawns
@export var min_spawn_distance: float = 300.0  # Distância mínima do player
@export var max_spawn_distance: float = 600.0  # Distância máxima do player
@export var max_enemies_on_screen: int = 20  # Máximo de inimigos simultâneos

# ===== DIFICULDADE PROGRESSIVA =====
@export var difficulty_increase_interval: float = 30.0  # A cada X segundos aumenta dificuldade
@export var spawn_interval_decrease: float = 0.1  # Quanto diminui o intervalo
@export var min_spawn_interval: float = 0.5  # Intervalo mínimo de spawn

# ===== CENAS DE INIMIGOS =====
@export var enemy_scene: PackedScene  # Cena base do inimigo
@export var enemy_data_list: Array[Resource] = []  # Lista de EnemyData

# ===== REFERÊNCIAS =====
var player: CharacterBody2D = null
var spawn_timer: float = 0.0
var difficulty_timer: float = 0.0
var current_difficulty: int = 1
var enemies_spawned: int = 0
var active_enemies: int = 0


func _ready() -> void:
	print("[SPAWNER] Sistema de spawn inicializado")
	
	# Encontra o player
	await get_tree().process_frame
	find_player()
	
	if not player:
		push_error("[SPAWNER] Player não encontrado!")
		spawn_enabled = false
		return
	
	# Carrega cena de inimigo se não foi definida
	if not enemy_scene:
		enemy_scene = load("res://scenes/enemy/enemy.tscn")
		print("[SPAWNER] Cena de inimigo carregada automaticamente")
	
	# Carrega dados de inimigos se a lista estiver vazia
	if enemy_data_list.is_empty():
		load_default_enemy_data()
	
	print("[SPAWNER] ✅ Sistema pronto para spawnar!")
	print("[SPAWNER]    Intervalo inicial: %.1fs" % spawn_interval)
	print("[SPAWNER]    Tipos de inimigos: %d" % enemy_data_list.size())


func _process(delta: float) -> void:
	if not spawn_enabled or not player or player.is_dead:
		return
	
	# Atualiza timer de spawn
	spawn_timer += delta
	
	# Atualiza dificuldade
	difficulty_timer += delta
	if difficulty_timer >= difficulty_increase_interval:
		increase_difficulty()
		difficulty_timer = 0.0
	
	# Verifica se deve spawnar
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		attempt_spawn()


func find_player() -> void:
	"""Encontra o player na cena"""
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0] as CharacterBody2D
		print("[SPAWNER] Player encontrado: ", player.name)
	else:
		print("[SPAWNER] ⚠️ Player não encontrado!")


func load_default_enemy_data() -> void:
	"""Carrega dados padrão de inimigos"""
	var wolf_data = load("res://resources/enemies/wolf_fast.tres")
	if wolf_data:
		enemy_data_list.append(wolf_data)
		print("[SPAWNER] Dados padrão carregados: wolf_fast")


func attempt_spawn() -> void:
	"""Tenta spawnar um inimigo"""
	# Verifica limite de inimigos
	count_active_enemies()
	
	if active_enemies >= max_enemies_on_screen:
		print("[SPAWNER] ⚠️ Limite de inimigos atingido (%d/%d)" % [active_enemies, max_enemies_on_screen])
		return
	
	# Spawna inimigo
	spawn_enemy()


func spawn_enemy() -> void:
	"""Spawna um inimigo em posição aleatória"""
	if not enemy_scene or enemy_data_list.is_empty():
		push_error("[SPAWNER] Cena ou dados de inimigo não configurados!")
		return
	
	# Cria instância do inimigo
	var enemy = enemy_scene.instantiate()
	
	if not enemy:
		push_error("[SPAWNER] Falha ao instanciar inimigo!")
		return
	
	# Escolhe dados aleatórios
	var random_data = enemy_data_list.pick_random()
	enemy.enemy_data = random_data
	
	# Calcula posição aleatória ao redor do player
	var spawn_pos = get_random_spawn_position()
	enemy.global_position = spawn_pos
	
	# Adiciona à cena
	get_parent().add_child(enemy)
	
	# Estatísticas
	enemies_spawned += 1
	active_enemies += 1
	
	print("[SPAWNER] 👹 Inimigo spawnado #%d: %s em %v" % [enemies_spawned, random_data.enemy_name, spawn_pos])
	print("[SPAWNER]    Inimigos ativos: %d/%d" % [active_enemies, max_enemies_on_screen])


func get_random_spawn_position() -> Vector2:
	"""Retorna posição aleatória ao redor do player"""
	if not player:
		return Vector2.ZERO
	
	# Escolhe ângulo aleatório
	var angle = randf() * TAU  # TAU = 2 * PI (círculo completo)
	
	# Escolhe distância aleatória entre min e max
	var distance = randf_range(min_spawn_distance, max_spawn_distance)
	
	# Calcula posição
	var offset = Vector2(cos(angle), sin(angle)) * distance
	var spawn_pos = player.global_position + offset
	
	return spawn_pos


func count_active_enemies() -> void:
	"""Conta quantos inimigos estão ativos na cena"""
	var enemies = get_tree().get_nodes_in_group("enemies")
	active_enemies = enemies.size()


func increase_difficulty() -> void:
	"""Aumenta a dificuldade do jogo"""
	current_difficulty += 1
	
	# Diminui intervalo de spawn (inimigos aparecem mais rápido)
	spawn_interval = max(spawn_interval - spawn_interval_decrease, min_spawn_interval)
	
	# Aumenta limite de inimigos (opcional)
	max_enemies_on_screen += 2
	
	print("[SPAWNER] 📈 DIFICULDADE AUMENTADA!")
	print("[SPAWNER]    Nível: %d" % current_difficulty)
	print("[SPAWNER]    Intervalo: %.2fs" % spawn_interval)
	print("[SPAWNER]    Máx. Inimigos: %d" % max_enemies_on_screen)


func stop_spawning() -> void:
	"""Para o sistema de spawn"""
	spawn_enabled = false
	print("[SPAWNER] ⏹️ Sistema de spawn pausado")


func resume_spawning() -> void:
	"""Resume o sistema de spawn"""
	spawn_enabled = true
	print("[SPAWNER] ▶️ Sistema de spawn resumido")


func reset_spawner() -> void:
	"""Reseta o spawner para estado inicial"""
	spawn_timer = 0.0
	difficulty_timer = 0.0
	current_difficulty = 1
	enemies_spawned = 0
	active_enemies = 0
	spawn_interval = 3.0  # Valor inicial
	max_enemies_on_screen = 20
	print("[SPAWNER] 🔄 Spawner resetado")
