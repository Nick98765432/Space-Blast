extends Node2D
class_name pathfinding

var parent
var player
@export var speed: float = 1000
@onready var line_of_sight: RayCast2D = $lineOfSight
@onready var sight_timer: Timer = $sightTimer
@onready var path_finding: NavigationAgent2D = $pathfinding


func _ready() -> void:
	await get_tree().create_timer(0.01).timeout
	parent = get_parent()
	player = parent.player

func _physics_process(delta: float) -> void:
	await get_tree().create_timer(0.01).timeout
	line_of_sight.target_position = to_local(player.global_position)
	line_of_sight.force_raycast_update()
	
func makePath():
	path_finding.target_position = player.global_position

func _on_sight_timer_timeout() -> void:
	makePath()

func moveTowardsPath():
	parent.enemy_sprite.look_at(path_finding.get_next_path_position())
	var dir = to_local(path_finding.get_next_path_position()).normalized()
	parent.velocity += (speed) * dir * get_physics_process_delta_time()
	if parent.global_position.distance_to(player.global_position) < 3:
		parent.velocity += (speed) * dir * get_physics_process_delta_time() * 50
	
func lineOfSight():
	return line_of_sight.get_collider() == player
