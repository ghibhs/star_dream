extends Node2D

# ===== MÚSICA =====
var game_music: AudioStreamPlayer = null


func _ready() -> void:
	print("[THE_GAME] 🎮 Cena do jogo carregada")
	
	# Configura e toca música do jogo
	setup_game_music()
	
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
