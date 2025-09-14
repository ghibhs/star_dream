extends Area2D

var speed:= 50
var direction:= 1

func _physics_process(delta: float) -> void:
	position.x += speed * direction


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
