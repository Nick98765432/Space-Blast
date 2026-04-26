extends Node2D
class_name beamRay

var beamState: int = -1
@export var parent: CharacterBody2D
@export var range: float = 1000
@export var colourOne: Gradient
@export var colourTwo: Gradient
@export var colourThree: Gradient
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var beam: Line2D = $beam



func _process(delta: float) -> void:
	match beamState:
		0:
			beam.width = lerpf(beam.width, 10, 1.5 * delta)
			ray_cast_2d.target_position = to_local(parent.player.global_position)
			ray_cast_2d.force_raycast_update()
			beam.points[1] = parent.global_position
			beam.points[0] = ray_cast_2d.get_collision_point()
		1:
			beam.width = lerpf(beam.width, 0.1, 6 * delta)
			if beam.width < 1:
				beam.hide()
				beamState = -1
	
func shoot():
	beam.points[1] = parent.global_position
	beam.points[0] = (parent.player.global_position - global_position).normalized() * range
	beam.gradient = colourOne
	beamState = 0
	beam.show()
	await get_tree().create_timer(0.5).timeout
	beam.gradient = colourTwo
	await get_tree().create_timer(0.5).timeout
	beam.gradient = colourThree
	beam.width = 20
	var start = global_position
	var direction = (parent.player.global_position - start).normalized()
	beam.points[1] = parent.global_position
	beam.points[0] = start + direction * range
	ray_cast_2d.target_position = to_local(beam.points[0])
	ray_cast_2d.force_raycast_update()
	if ray_cast_2d.is_colliding():
		if ray_cast_2d.get_collider() is Player:
			var player = ray_cast_2d.get_collider()
			player.damage(50)
		else:
			beam.points[0] = (ray_cast_2d.get_collision_point())
	beamState = 1
