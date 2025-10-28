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
	
	# ⚠️ CRÍTICO: Permite que esta UI funcione mesmo quando o jogo está pausado
	process_mode = Node.PROCESS_MODE_ALWAYS
	print("[GAME_OVER]    ✅ Process mode configurado para ALWAYS")
	
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
	print("[GAME_OVER] 🔄 VERSÃO NOVA - Carregando the_game.tscn")
	
	# Despausa o jogo
	get_tree().paused = false
	print("[GAME_OVER]    Jogo despausado")
	
	# Reseta estatísticas
	if has_node("/root/GameStats"):
		get_node("/root/GameStats").reset_stats()
		print("[GAME_OVER]    Estatísticas resetadas")
	
	# Recarrega a CENA DO JOGO (não a cena atual que é o game_over)
	var game_scene_path = "res://scenes/game/the_game.tscn"
	
	print("[GAME_OVER]    Verificando se arquivo existe: ", game_scene_path)
	if ResourceLoader.exists(game_scene_path):
		print("[GAME_OVER]    ✅ Arquivo encontrado!")
		print("[GAME_OVER]    Chamando change_scene_to_file()...")
		get_tree().change_scene_to_file(game_scene_path)
		print("[GAME_OVER]    ✅ Jogo reiniciado")
	else:
		push_error("Cena do jogo não encontrada: " + game_scene_path)
		print("[GAME_OVER]    ❌ ERRO: Cena do jogo não encontrada!")



func _on_menu_button_pressed() -> void:
	print("[GAME_OVER] 🏠 Botão MENU PRINCIPAL pressionado")
	print("[GAME_OVER] 🏠 VERSÃO NOVA - Carregando main_menu.tscn")
	
	# Despausa o jogo
	get_tree().paused = false
	print("[GAME_OVER]    Jogo despausado")
	
	# Reseta estatísticas
	if has_node("/root/GameStats"):
		get_node("/root/GameStats").reset_stats()
		print("[GAME_OVER]    Estatísticas resetadas")
	
	# Vai para o menu principal
	var menu_scene_path = "res://scenes/ui/main_menu.tscn"
	
	print("[GAME_OVER]    Verificando se arquivo existe: ", menu_scene_path)
	if ResourceLoader.exists(menu_scene_path):
		print("[GAME_OVER]    ✅ Arquivo encontrado!")
		print("[GAME_OVER]    Chamando change_scene_to_file()...")
		get_tree().change_scene_to_file(menu_scene_path)
		print("[GAME_OVER]    ✅ Voltando para menu principal")
	else:
		push_error("Menu principal não encontrado: " + menu_scene_path)
		print("[GAME_OVER]    ❌ ERRO: Menu não encontrado!")



func _on_quit_button_pressed() -> void:
	print("[GAME_OVER] 🚪 Botão SAIR pressionado")
	print("[GAME_OVER] Fechando o jogo...")
	get_tree().quit()
