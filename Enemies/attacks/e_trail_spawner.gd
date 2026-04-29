extends Node2D
class_name explosionSpawner

var explosion: PackedScene = preload("res://Enemies/attacks/ExplosionTrail.tscn")
@export var active: bool = false
@onready var spacing: Area2D = $Spacing


func _process(delta: float) -> void:
	if active:
		var canPlace: bool = true
		for i in spacing.get_overlapping_areas():
			if i.get_parent() is explosionTrail:
				canPlace = false
		if canPlace:
			place()

func activate():
	active = true

func deactivate():
	active = false
	
func place():
	var trail = explosion.instantiate()
	trail.global_position = global_position
	get_tree().get_root().add_child(trail)
