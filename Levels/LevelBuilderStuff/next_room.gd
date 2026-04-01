extends Area2D



func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.encounter.y = 0
		body.encounter.x += 1
		body.spawnLocation = global_position
		Signals.emit_signal("change")
		queue_free()
