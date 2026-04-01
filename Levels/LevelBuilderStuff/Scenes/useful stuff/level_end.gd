extends Node2D

@export var next_level: PackedScene
@onready var camera = get_tree().get_first_node_in_group("camera")


func _on_camera_lock_body_entered(body: Node2D) -> void:
	if body is Player:
		camera.lock = true


func _on_next_level_body_entered(body: Node2D) -> void:
	if body is Player:
		get_tree().change_scene_to_packed(next_level)
