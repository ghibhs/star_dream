extends Node

# ===== CONFIGURAÇÕES DE ÁUDIO =====
var master_volume: float = 100.0
var music_volume: float = 100.0
var sfx_volume: float = 100.0

# ===== ÍNDICES DOS BUS =====
var master_bus_idx: int
var music_bus_idx: int
var sfx_bus_idx: int


func _ready() -> void:
	print("[AUDIO_MANAGER] Sistema de áudio inicializado")
	setup_audio_buses()
	load_settings()
	apply_settings()


func setup_audio_buses() -> void:
	"""Configura os bus de áudio necessários"""
	master_bus_idx = AudioServer.get_bus_index("Master")
	music_bus_idx = AudioServer.get_bus_index("Music")
	sfx_bus_idx = AudioServer.get_bus_index("SFX")
	
	# Cria bus de música se não existir
	if music_bus_idx == -1:
		music_bus_idx = AudioServer.bus_count
		AudioServer.add_bus(music_bus_idx)
		AudioServer.set_bus_name(music_bus_idx, "Music")
		AudioServer.set_bus_send(music_bus_idx, "Master")
		print("[AUDIO_MANAGER] Bus 'Music' criado")
	
	# Cria bus de SFX se não existir
	if sfx_bus_idx == -1:
		sfx_bus_idx = AudioServer.bus_count
		AudioServer.add_bus(sfx_bus_idx)
		AudioServer.set_bus_name(sfx_bus_idx, "SFX")
		AudioServer.set_bus_send(sfx_bus_idx, "Master")
		print("[AUDIO_MANAGER] Bus 'SFX' criado")


func load_settings() -> void:
	"""Carrega configurações salvas"""
	# Por enquanto usa valores padrão
	# Futuramente pode carregar de arquivo
	print("[AUDIO_MANAGER] Configurações carregadas (valores padrão)")


func save_settings() -> void:
	"""Salva configurações atuais"""
	# Por enquanto não persiste entre sessões
	# Futuramente pode salvar em arquivo
	print("[AUDIO_MANAGER] Configurações salvas na memória")


func apply_settings() -> void:
	"""Aplica as configurações aos bus de áudio"""
	set_master_volume(master_volume)
	set_music_volume(music_volume)
	set_sfx_volume(sfx_volume)
	print("[AUDIO_MANAGER] Configurações aplicadas")


func set_master_volume(value: float) -> void:
	"""Define o volume master (0-100)"""
	master_volume = clamp(value, 0.0, 100.0)
	var db = linear_to_db(master_volume / 100.0)
	AudioServer.set_bus_volume_db(master_bus_idx, db)


func set_music_volume(value: float) -> void:
	"""Define o volume da música (0-100)"""
	music_volume = clamp(value, 0.0, 100.0)
	var db = linear_to_db(music_volume / 100.0)
	AudioServer.set_bus_volume_db(music_bus_idx, db)


func set_sfx_volume(value: float) -> void:
	"""Define o volume dos efeitos sonoros (0-100)"""
	sfx_volume = clamp(value, 0.0, 100.0)
	var db = linear_to_db(sfx_volume / 100.0)
	AudioServer.set_bus_volume_db(sfx_bus_idx, db)


func get_master_volume() -> float:
	return master_volume


func get_music_volume() -> float:
	return music_volume


func get_sfx_volume() -> float:
	return sfx_volume


func linear_to_db(linear: float) -> float:
	"""Converte linear (0.0 a 1.0) para decibéis"""
	if linear <= 0.0:
		return -80.0  # Silêncio
	return 20.0 * log(linear) / log(10.0)


func db_to_linear(db: float) -> float:
	"""Converte decibéis para linear (0.0 a 1.0)"""
	return pow(10.0, db / 20.0)
