extends Node2D
class_name explosionSpawner

var explosion: PackedScene = preload("res://Enemies/attacks/ExplosionTrail.tscn")
var frames: int
var framesLeft: int = 0
var spacing: float = 160
@export var active: bool = false

func _ready() -> void:
	if get_parent() is rocket:
		findFrames(get_parent().speed)
	
func _process(delta: float) -> void:
	if active:
		if framesLeft <= 0:
			place()
			framesLeft = frames
		else:
			framesLeft -= 1


func activate():
	active = true

func deactivate():
	active = false
	
func place():
	var trail = explosion.instantiate()
	trail.global_position = global_position
	get_tree().get_root().add_child(trail)

func findFrames(speed):
	frames = ceil(spacing / (speed / 60))
