extends Area2D

@export var changeMusic: bool = false
@export var current: AudioStreamPlayer
@export var newMusic: AudioStreamWAV

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.encounter.y = 0
		body.encounter.x += 1
		body.spawnLocation = global_position
		Signals.emit_signal("change")
		if changeMusic:
			current.stream = newMusic
			current.play()
		queue_free()
