extends Node2D


func _ready() -> void:
	print("[THE_GAME] 🎮 Cena do jogo carregada")
	
	# Inicia o contador de tempo e estatísticas
	if has_node("/root/GameStats"):
		get_node("/root/GameStats").start_game()
		print("[THE_GAME] ✅ Sistema de estatísticas iniciado")
	else:
		push_error("[THE_GAME] ❌ GameStats autoload não encontrado!")


func _exit_tree() -> void:
	# Para o contador quando sair da cena
	if has_node("/root/GameStats"):
		get_node("/root/GameStats").stop_game()
		print("[THE_GAME] ⏹️ Sistema de estatísticas pausado")
