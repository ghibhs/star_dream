extends CanvasLayer

# ===== REFERÊNCIAS DOS BOTÕES =====
@onready var start_button: Button = $CenterContainer/VBoxContainer/StartButton
@onready var options_button: Button = $CenterContainer/VBoxContainer/OptionsButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton


func _ready() -> void:
	print("[MAIN_MENU] Menu principal inicializado")
	
	# Foca no botão de início para navegação por teclado
	if start_button:
		start_button.grab_focus()
		print("[MAIN_MENU] Botão INICIAR focado")


func _on_start_button_pressed() -> void:
	print("[MAIN_MENU] 🎮 Botão INICIAR JOGO pressionado")
	start_game()


func _on_options_button_pressed() -> void:
	print("[MAIN_MENU] ⚙️ Botão OPÇÕES pressionado")
	# TODO: Implementar tela de opções
	print("[MAIN_MENU]    Tela de opções ainda não implementada")


func _on_quit_button_pressed() -> void:
	print("[MAIN_MENU] 🚪 Botão SAIR pressionado")
	quit_game()


func start_game() -> void:
	print("[MAIN_MENU] Iniciando jogo...")
	print("[MAIN_MENU]    Carregando cena: res://the_game.tscn")
	
	# Carrega a cena do jogo
	var game_scene_path = "res://the_game.tscn"
	
	# Verifica se a cena existe
	if ResourceLoader.exists(game_scene_path):
		get_tree().change_scene_to_file(game_scene_path)
		print("[MAIN_MENU]    ✅ Transição para jogo iniciada")
	else:
		push_error("Cena do jogo não encontrada: " + game_scene_path)
		print("[MAIN_MENU]    ❌ ERRO: Cena não encontrada!")


func quit_game() -> void:
	print("[MAIN_MENU] Fechando o jogo...")
	get_tree().quit()
	print("[MAIN_MENU]    ✅ Jogo encerrado")
