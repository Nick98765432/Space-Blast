extends Node2D
class_name hitstopFix
#this fix doesn't work
func _ready() -> void:
	Hitstops.connect("stopped", _on_stop)
	Hitstops.connect("stopped", _on_done)


func _on_stop():
	if Hitstops.isStopped:
		get_parent().velocity = Vector2.ZERO
		get_parent().global_position = get_parent().global_position
func _on_done():
	get_parent().reset_physics_interpolation()
