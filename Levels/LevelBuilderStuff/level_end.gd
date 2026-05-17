extends Node2D

var endScreen: PackedScene = preload("res://Levels/level end/End of Level.tscn")
@export var currentLevel: int
@export var next_level: PackedScene 
@export var fade: AnimationPlayer
@onready var camera = get_tree().get_first_node_in_group("camera")


func _on_camera_lock_body_entered(body: Node2D) -> void:
	if body is Player:
		camera.lock = true


func _on_next_level_body_entered(body: Node2D) -> void:
	if body is Player:
		body.speed = 0
		fade.play("new_animation")
		await get_tree().create_timer(1).timeout
		PlayerData.level = currentLevel
		PlayerData.nextLevel = next_level
		get_tree().change_scene_to_packed(endScreen)
