extends AudioStreamPlayer
signal music


func _on_finished() -> void:
	emit_signal("music")
