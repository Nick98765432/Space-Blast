extends StaticBody2D
@export var player: Player
@export var disappearCondition: Vector2i
@export var appearCondition: Vector2i



func _process(delta: float) -> void:
	if player.encounter == disappearCondition:
		$CollisionShape2D.disabled = true
	if player.encounter == appearCondition:
		$CollisionShape2D.disabled = false
