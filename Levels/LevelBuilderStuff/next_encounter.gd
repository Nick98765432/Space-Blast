extends Area2D

var player: Player
@export var returnCond: Vector2i

func _ready() -> void:
	Signals.connect("destroy", _on_destroy)
	
	
func _on_destroy():
	if player != null:
		if returnCond == player.encounter:
			monitoring = true

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body
		player.encounter.y += 1
		Signals.change.emit()
		await get_tree().create_timer(0.01).timeout
		monitoring = false
