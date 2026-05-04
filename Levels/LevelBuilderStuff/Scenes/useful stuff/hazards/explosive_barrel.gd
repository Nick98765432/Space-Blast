extends StaticBody2D
class_name explosiveBarrel

var explosion: PackedScene = preload("res://Player/playerExplosion.tscn")
var range: float = 40

func _ready() -> void:
	Signals.connect("destroy", _on_respawn)

func explode():
	for i in 5:
		var rand = randf_range(-range, range)
		var rand2 = randf_range(-range, range)
		createExplosion(global_position + Vector2(rand, rand2))

func createExplosion(pos):
	var boom = explosion.instantiate()
	boom.global_position = pos
	get_tree().get_root().add_child(boom)
	hide()
	$CollisionShape2D.disabled = true
	set_collision_layer_value(1, false)

func _on_respawn():
	show()
	set_collision_layer_value(1, true)
	$CollisionShape2D.disabled = false
