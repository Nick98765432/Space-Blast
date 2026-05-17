extends Area2D


var value: int



func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		PlayerData.weapons.append(value)
		$AudioStreamPlayer.play()
		$CollisionShape2D.queue_free()
		hide()


func _on_audio_stream_player_finished() -> void:
	queue_free()
