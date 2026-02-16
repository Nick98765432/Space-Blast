extends Node2D
class_name projBrain

var parent
var player
var sideDir = 90
var movementDir
var state = 1
@export var speed = 500

func _ready() -> void:
	await get_tree().create_timer(0.01).timeout
	parent = get_parent()
	player = get_parent().player

func move():
	var delta = get_physics_process_delta_time()
	movementDir = to_local(player.global_position).normalized()
	parent.velocity += (movementDir * speed * delta).rotated(deg_to_rad(sideDir))
	if state == 1:
		parent.velocity += movementDir * speed * delta
		if parent.global_position.distance_to(player.global_position) < 100:
			if $stateChange.time_left <= 0:
				$stateChange.start()
	if state == 2:
		parent.velocity -= movementDir * speed * delta
		if parent.global_position.distance_to(player.global_position) > 100:
			if $stateChange.time_left <= 0:
				$stateChange.start()
		
	parent.velocity *= 0.85
	parent.move_and_slide()

func _on_dir_timer_timeout() -> void:
	changeDir()

func changeDir():
	if randi_range(0,1) == 0:
		sideDir = 90
	else:
		sideDir = 270

func _on_state_change_timeout() -> void:
	if state == 1:
		if global_position.distance_to(player.global_position) < 100:
			state = 2
	if state == 2:
		if global_position.distance_to(player.global_position) > 100:
			state = 1
