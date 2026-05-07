extends Area2D
class_name explosion


var damageDone: bool = false

func _ready() -> void:
	Signals.emit_signal("shakeSmall")

func _process(delta: float) -> void:
	if not damageDone:
		for i in get_overlapping_bodies():
			if i is Player:
				i.damage(30)
				damageDone = true


func _on_explosion_sprite_animation_finished() -> void:
	queue_free()
