extends CanvasLayer

# ===== REFERÊNCIAS DOS BOTÕES =====
@onready var start_button: Button = $CenterContainer/VBoxContainer/StartButton
@onready var options_button: Button = $CenterContainer/VBoxContainer/OptionsButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton

var buttons: Array[Button] = []
var current_index: int = 0


func _ready() -> void:
	print("[MAIN_MENU] Menu principal inicializado")
	
	# Desabilita focus padrão dos botões (WASD não navega)
	start_button.focus_mode = Control.FOCUS_NONE
	options_button.focus_mode = Control.FOCUS_NONE
	quit_button.focus_mode = Control.FOCUS_NONE
	
	# Adiciona botões à lista
	buttons = [start_button, options_button, quit_button]
	
	# Destaca o primeiro botão
	highlight_button(0)
	print("[MAIN_MENU] Navegação por SETAS configurada")


func _input(event: InputEvent) -> void:
	# Navegação com SETAS (navigate_up/down) - universal
	if event.is_action_pressed("navigate_up"):
		navigate(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("navigate_down"):
		navigate(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("navigate_select") or event.is_action_pressed("ui_accept"):
		activate_current_button()
		get_viewport().set_input_as_handled()


func navigate(direction: int) -> void:
	# Remove highlight do botão atual
	buttons[current_index].modulate = Color.WHITE
	
	# Calcula novo índice
	current_index = (current_index + direction) % buttons.size()
	if current_index < 0:
		current_index = buttons.size() + current_index
	
	# Destaca novo botão
	highlight_button(current_index)
	print("[MAIN_MENU] 🎯 Navegando para: %s" % buttons[current_index].text)


func highlight_button(index: int) -> void:
	buttons[index].modulate = Color(1.5, 1.5, 0.5)  # Amarelo


func activate_current_button() -> void:
	buttons[current_index].emit_signal("pressed")
	print("[MAIN_MENU] ✅ Ativando: %s" % buttons[current_index].text)


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
	print("[MAIN_MENU]    Carregando cena: res://scenes/game/the_game.tscn")
    
	# Carrega a cena do jogo (novo local após reorganização)
	var game_scene_path = "res://scenes/game/the_game.tscn"
	
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
