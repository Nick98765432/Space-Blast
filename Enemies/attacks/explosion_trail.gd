extends Node2D
class_name explosionTrail

var explosion: PackedScene = preload("res://Enemies/attacks/Explosion.tscn")

@export var time: float = 1

func _ready() -> void:
	await get_tree().create_timer(time).timeout
	explode()

func explode():
	var boom = explosion.instantiate()
	boom.global_position = global_position
	get_tree().get_root().add_child(boom)
	queue_free()
