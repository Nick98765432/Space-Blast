extends Node2D
class_name v2Brain

var hit: bool = false
var movementDir: Vector2
var sideDir = 90
var dir: Vector2
var center: Vector2
var state = 1
var parent: CharacterBody2D
var player: Player
var attacks: AttacksComp
@export var distance: float = 120
@export var speed: float = 3600
@onready var paths: = $Paths.get_children()
@onready var dir_timer: Timer = $dirTimer


func _ready() -> void:
	await get_tree().create_timer(0.01).timeout
	parent = get_parent()
	player = get_parent().player
	attacks = get_parent().attacks
	changeDir()
	parent.health_handler.connect("hit", _on_hit)
	for i in paths.size():
		paths[i].target_position = paths[i].target_position.rotated(deg_to_rad(i * (360/paths.size())))

func move():
	if not attacks.isAttacking:
		center = player.current + player.screenSize * 0.5
		movementDir = to_local(player.global_position).normalized()
		if state == 1:
			if parent.global_position.distance_to(player.global_position) < distance:
				findPath(180)
			else:
				findPath(0)
		if state == 2:
			parent.velocity += dir * speed * 1.25 * get_physics_process_delta_time()
		parent.velocity *= 0.85

func findPath(dir: float):
	var highest: choice
	for i in paths.size():
		paths[i].weight = cos(paths[i].target_position.normalized().angle_to(movementDir.rotated(deg_to_rad(dir))))
		paths[i].weight += cos(paths[i].target_position.normalized().angle_to(movementDir.rotated(deg_to_rad(sideDir))))
		paths[i].weight += cos(paths[i].target_position.normalized().angle_to((to_local(center)))) * 0.5
		if paths[i].is_colliding():
			if i - 1 >= 0:
				paths[i - 1].weight -= 3
			else:
				paths[paths.size() - 1].weight -= 3
			if i - 2 >= 0:
				paths[i - 2].weight -= 3
			else:
				paths[paths.size() - 2].weight -= 3
			paths[i].weight -= 5
			if i + 1 < paths.size():
				paths[i + 1].weight -= 3
			else:
				paths[0].weight -= 3
			if i + 2 < paths.size():
				paths[i + 2].weight -= 3
			else:
				paths[1].weight -= 3
		if highest == null or paths[i].weight > highest.weight:
			highest = paths[i]
	parent.velocity  += highest.target_position.normalized() * speed * get_physics_process_delta_time()

func changeDir():
	state = 2
	dir = movementDir
	parent.velocity = Vector2.ZERO
	await get_tree().create_timer(0.3).timeout
	if sideDir == 270:
		sideDir = 90
	else:
		sideDir = 270
	state = 1
	
func _on_hit():
	if not hit:
		hit = true
		await get_tree().create_timer(0.5).timeout
		if sideDir == 270:
			sideDir = 90
		else:
			sideDir = 270
		hit = false

func _on_dir_timer_timeout() -> void:
	changeDir()
	dir_timer.start(randf_range(2, 3))
