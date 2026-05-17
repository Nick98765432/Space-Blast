extends Node2D
@export var text: String


func _ready() -> void:
	hide()
	$Area2D/CanvasLayer.hide()
	$Area2D/CanvasLayer/Control/ColorRect/Label.text = text




func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		show()
		$Area2D/CanvasLayer.show()
		await get_tree().create_timer(5).timeout
		queue_free()
