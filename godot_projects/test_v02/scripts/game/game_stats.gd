extends Node

# ===== ESTATÍSTICAS DO JOGO =====
var enemies_defeated: int = 0
var survival_time: float = 0.0
var game_started: bool = false


func _ready() -> void:
	print("[GAME_STATS] Sistema de estatísticas inicializado")


func _process(delta: float) -> void:
	# Conta tempo de sobrevivência
	if game_started:
		survival_time += delta


func start_game() -> void:
	print("[GAME_STATS] 🎮 Jogo iniciado, resetando estatísticas")
	enemies_defeated = 0
	survival_time = 0.0
	game_started = true


func stop_game() -> void:
	print("[GAME_STATS] ⏹️ Jogo pausado")
	game_started = false


func enemy_defeated() -> void:
	enemies_defeated += 1
	print("[GAME_STATS] 💀 Inimigo derrotado! Total: %d" % enemies_defeated)


func reset_stats() -> void:
	print("[GAME_STATS] 🔄 Resetando estatísticas")
	enemies_defeated = 0
	survival_time = 0.0
	game_started = false
