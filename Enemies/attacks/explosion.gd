extends Area2D
class_name explosion


var damageDone: bool = false

func _ready() -> void:
	await get_tree().create_timer(0.2).timeout
	queue_free()


func _process(delta: float) -> void:
	if not damageDone:
		for i in get_overlapping_bodies():
			if i is Player:
				i.damage(40)
				damageDone = true
