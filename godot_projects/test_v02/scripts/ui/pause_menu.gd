extends CanvasLayer

# ===== REFERÊNCIAS DOS BOTÕES =====
@onready var continue_button: Button = $CenterContainer/VBoxContainer/ContinueButton
@onready var restart_button: Button = $CenterContainer/VBoxContainer/RestartButton
@onready var menu_button: Button = $CenterContainer/VBoxContainer/MenuButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton


func _ready() -> void:
	print("[PAUSE_MENU] Menu de pausa inicializado")
	
	# Esconde o menu por padrão
	hide()
	
	# Foca no botão continuar quando aparecer
	if continue_button:
		continue_button.grab_focus()


func _input(event: InputEvent) -> void:
	# Tecla ESC para pausar/despausar
	if event.is_action_pressed("ui_cancel"):
		print("[PAUSE_MENU] Tecla ESC pressionada")
		toggle_pause()


func toggle_pause() -> void:
	if get_tree().paused:
		print("[PAUSE_MENU] ▶️ Despausando jogo")
		resume_game()
	else:
		print("[PAUSE_MENU] ⏸️ Pausando jogo")
		pause_game()


func pause_game() -> void:
	get_tree().paused = true
	show()
	print("[PAUSE_MENU] Jogo pausado")
	
	# Foca no botão continuar
	if continue_button:
		continue_button.grab_focus()


func resume_game() -> void:
	get_tree().paused = false
	hide()
	print("[PAUSE_MENU] Jogo despausado")


func _on_continue_button_pressed() -> void:
	print("[PAUSE_MENU] ▶️ Botão CONTINUAR pressionado")
	resume_game()


func _on_restart_button_pressed() -> void:
	print("[PAUSE_MENU] 🔄 Botão REINICIAR pressionado")
	
	# Despausa e recarrega
	get_tree().paused = false
	get_tree().reload_current_scene()
	print("[PAUSE_MENU]    ✅ Cena recarregada")


func _on_menu_button_pressed() -> void:
	print("[PAUSE_MENU] 🏠 Botão MENU PRINCIPAL pressionado")
	
	# Despausa e vai para menu
	get_tree().paused = false
	
	var menu_scene_path = "res://main_menu.tscn"
	if ResourceLoader.exists(menu_scene_path):
		get_tree().change_scene_to_file(menu_scene_path)
		print("[PAUSE_MENU]    ✅ Voltando para menu principal")
	else:
		push_error("Menu principal não encontrado: " + menu_scene_path)
		print("[PAUSE_MENU]    ⚠️ Menu não encontrado!")


func _on_quit_button_pressed() -> void:
	print("[PAUSE_MENU] 🚪 Botão SAIR pressionado")
	print("[PAUSE_MENU] Fechando o jogo...")
	get_tree().quit()
