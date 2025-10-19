extends CanvasLayer

# ===== NODES =====
@onready var stats_label: Label = $CenterContainer/VBoxContainer/StatsLabel
@onready var restart_button: Button = $CenterContainer/VBoxContainer/RestartButton
@onready var menu_button: Button = $CenterContainer/VBoxContainer/MenuButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton

# ===== ESTATÍSTICAS =====
var enemies_defeated: int = 0
var survival_time: float = 0.0


func _ready() -> void:
	print("[GAME_OVER] Tela de Game Over inicializada")
	
	# Pausa o jogo
	get_tree().paused = true
	print("[GAME_OVER] Jogo pausado")
	
	# Atualiza estatísticas
	update_stats()
	
	# Foca no botão de reiniciar
	restart_button.grab_focus()


func update_stats() -> void:
	# Tenta obter estatísticas do autoload (se existir)
	if has_node("/root/GameStats"):
		var game_stats = get_node("/root/GameStats")
		enemies_defeated = game_stats.enemies_defeated
		survival_time = game_stats.survival_time
	
	# Formata tempo
	var minutes = int(survival_time / 60.0)
	var seconds = int(survival_time) % 60
	var time_text = "%02d:%02d" % [minutes, seconds]
	
	# Atualiza label
	stats_label.text = "Estatísticas:\nInimigos Derrotados: %d\nTempo Sobrevivido: %s" % [enemies_defeated, time_text]
	
	print("[GAME_OVER] Estatísticas:")
	print("[GAME_OVER]    Inimigos: %d" % enemies_defeated)
	print("[GAME_OVER]    Tempo: %s" % time_text)


func _on_restart_button_pressed() -> void:
	print("[GAME_OVER] 🔄 Botão REINICIAR pressionado")
	
	# Despausa o jogo
	get_tree().paused = false
	
	# Recarrega a cena atual
	get_tree().reload_current_scene()
	print("[GAME_OVER] Cena recarregada")


func _on_menu_button_pressed() -> void:
	print("[GAME_OVER] 🏠 Botão MENU PRINCIPAL pressionado")
	
	# Despausa o jogo
	get_tree().paused = false
	print("[GAME_OVER] Jogo despausado")
	
	# Vai para o menu principal
	var menu_scene_path = "res://main_menu.tscn"
	
	if ResourceLoader.exists(menu_scene_path):
		get_tree().change_scene_to_file(menu_scene_path)
		print("[GAME_OVER]    ✅ Voltando para menu principal")
	else:
		push_error("Menu principal não encontrado: " + menu_scene_path)
		print("[GAME_OVER]    ⚠️ Menu não encontrado, recarregando cena atual")
		get_tree().reload_current_scene()


func _on_quit_button_pressed() -> void:
	print("[GAME_OVER] 🚪 Botão SAIR pressionado")
	print("[GAME_OVER] Fechando o jogo...")
	get_tree().quit()
