extends Node2D


@export var red: bool = false
@export var blue: bool = false




func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		if red:
			body.keycards.append("red")
			giveKey()
		elif blue:
			body.keycards.append("blue")
			giveKey()

func giveKey():
	Signals.emit_signal("unlock")
	get_parent().queue_free()
