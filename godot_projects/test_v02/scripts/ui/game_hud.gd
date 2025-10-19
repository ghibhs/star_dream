extends CanvasLayer

# ===== REFERÊNCIAS =====
@onready var stats_label: Label = $StatsLabel


func _ready() -> void:
	print("[HUD] HUD inicializada")


func _process(_delta: float) -> void:
	update_stats()


func update_stats() -> void:
	if not has_node("/root/GameStats"):
		return
	
	var game_stats = get_node("/root/GameStats")
	
	# Formata tempo
	var minutes = int(game_stats.survival_time / 60.0)
	var seconds = int(game_stats.survival_time) % 60
	var time_text = "%02d:%02d" % [minutes, seconds]
	
	# Atualiza label
	if stats_label:
		stats_label.text = "Tempo: %s | Inimigos: %d" % [time_text, game_stats.enemies_defeated]
