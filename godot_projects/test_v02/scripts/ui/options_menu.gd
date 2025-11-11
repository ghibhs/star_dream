extends CanvasLayer

# ===== REFERÊNCIAS =====
@onready var master_slider: HSlider = $CenterContainer/VBoxContainer/MasterVolume/MasterSlider
@onready var music_slider: HSlider = $CenterContainer/VBoxContainer/MusicVolume/MusicSlider
@onready var sfx_slider: HSlider = $CenterContainer/VBoxContainer/SFXVolume/SFXSlider
@onready var back_button: Button = $CenterContainer/VBoxContainer/BackButton

@onready var master_label: Label = $CenterContainer/VBoxContainer/MasterVolume/MasterLabel
@onready var music_label: Label = $CenterContainer/VBoxContainer/MusicVolume/MusicLabel
@onready var sfx_label: Label = $CenterContainer/VBoxContainer/SFXVolume/SFXLabel

# ===== ÍNDICES DOS BUS DE ÁUDIO =====
var master_bus_idx: int
var music_bus_idx: int
var sfx_bus_idx: int


func _ready() -> void:
	print("[OPTIONS] Menu de opções inicializado")
	
	# Obtém os índices dos bus de áudio
	master_bus_idx = AudioServer.get_bus_index("Master")
	music_bus_idx = AudioServer.get_bus_index("Music")
	sfx_bus_idx = AudioServer.get_bus_index("SFX")
	
	# Se os bus não existirem, cria-os
	if music_bus_idx == -1:
		music_bus_idx = AudioServer.bus_count
		AudioServer.add_bus(music_bus_idx)
		AudioServer.set_bus_name(music_bus_idx, "Music")
		AudioServer.set_bus_send(music_bus_idx, "Master")
		print("[OPTIONS] Bus 'Music' criado")
	
	if sfx_bus_idx == -1:
		sfx_bus_idx = AudioServer.bus_count
		AudioServer.add_bus(sfx_bus_idx)
		AudioServer.set_bus_name(sfx_bus_idx, "SFX")
		AudioServer.set_bus_send(sfx_bus_idx, "Master")
		print("[OPTIONS] Bus 'SFX' criado")
	
	# Carrega volumes salvos
	load_audio_settings()
	
	# Conecta sinais dos sliders
	master_slider.value_changed.connect(_on_master_volume_changed)
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	
	# Conecta botão de voltar
	back_button.pressed.connect(_on_back_button_pressed)
	
	# Atualiza labels
	update_volume_labels()


func load_audio_settings() -> void:
	"""Carrega configurações de áudio do AudioManager"""
	if has_node("/root/AudioManager"):
		var audio_mgr = get_node("/root/AudioManager")
		master_slider.value = audio_mgr.get_master_volume()
		music_slider.value = audio_mgr.get_music_volume()
		sfx_slider.value = audio_mgr.get_sfx_volume()
		print("[OPTIONS] Configurações carregadas do AudioManager")
	else:
		# Fallback para valores padrão
		master_slider.value = 100.0
		music_slider.value = 100.0
		sfx_slider.value = 100.0
		print("[OPTIONS] AudioManager não encontrado, usando valores padrão")


func save_audio_settings() -> void:
	"""Salva as configurações de áudio no AudioManager"""
	if has_node("/root/AudioManager"):
		var audio_mgr = get_node("/root/AudioManager")
		audio_mgr.save_settings()
		print("[OPTIONS] Configurações salvas no AudioManager")
	else:
		print("[OPTIONS] ⚠️ AudioManager não encontrado")


func _on_master_volume_changed(value: float) -> void:
	"""Atualiza o volume master"""
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").set_master_volume(value)
	update_volume_labels()
	print("[OPTIONS] 🔊 Volume Master: %.0f%%" % value)


func _on_music_volume_changed(value: float) -> void:
	"""Atualiza o volume da música"""
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").set_music_volume(value)
	update_volume_labels()
	print("[OPTIONS] 🎵 Volume Música: %.0f%%" % value)


func _on_sfx_volume_changed(value: float) -> void:
	"""Atualiza o volume dos efeitos sonoros"""
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").set_sfx_volume(value)
	update_volume_labels()
	print("[OPTIONS] 🔊 Volume SFX: %.0f%%" % value)


func update_volume_labels() -> void:
	"""Atualiza os textos dos labels com os valores atuais"""
	master_label.text = "Volume Master: %.0f%%" % master_slider.value
	music_label.text = "Volume Música: %.0f%%" % music_slider.value
	sfx_label.text = "Volume SFX: %.0f%%" % sfx_slider.value


func _on_back_button_pressed() -> void:
	"""Volta para o menu principal"""
	print("[OPTIONS] Voltando ao menu principal")
	save_audio_settings()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")


func db_to_linear(db: float) -> float:
	"""Converte decibéis para linear (0.0 a 1.0)"""
	return pow(10.0, db / 20.0)


func linear_to_db(linear: float) -> float:
	"""Converte linear (0.0 a 1.0) para decibéis"""
	if linear <= 0.0:
		return -80.0  # Silêncio
	return 20.0 * log(linear) / log(10.0)
