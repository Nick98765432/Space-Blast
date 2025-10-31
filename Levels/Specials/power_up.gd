extends Area2D
@export var type: int = 1
var player: Node
var isPoweredUp: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.connect("destroy", _on_destroy)



func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		isPoweredUp = true
		player = body
		body.powerupMult *= 4
		$quad.hide()
		monitoring = false
		await get_tree().create_timer(5).timeout
		if isPoweredUp:
			body.powerupMult /= 4
			isPoweredUp = false

func _on_destroy():
	if player != null:
		player.powerupMult = 1
		isPoweredUp = false
		$quad.show()
		monitoring = true
