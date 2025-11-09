extends CharacterBody2D
class_name v2

var hit: bool = false
var dead = false
var speed = 3600
var attacking: bool = false
#movement
var movementDir: Vector2
#used for dash
var dir: Vector2
var sideDir = 90
var state = 1
var isParryable: bool = false
var paths: Array
var center: Vector2
var num: int = 0
var shot : PackedScene = preload("res://Enemies/attacks/enemy energy blast.tscn")
@export var player: Player
@onready var pathfinding: NavigationAgent2D = $pathfinding
@onready var sight_timer: Timer = $sightTimer
@onready var enemy_sprite: Sprite2D = $enemySprite
@onready var dir_timer: Timer = $dirTimer
@onready var shot_cool: Timer = $shotCool
@onready var parry_tele: GPUParticles2D = $parryTele
@onready var health_handler: healthHandler = $healthHandler
@onready var unparry_tele: GPUParticles2D = $unparryTele
@onready var full_charge: GPUParticles2D = $fullCharge
@onready var beep: AudioStreamPlayer = $Sounds/beep
@onready var shotgun_sfx: AudioStreamPlayer = $Sounds/shotgunSFX
@onready var shot_sfx: AudioStreamPlayer = $Sounds/shotSFX
@onready var shot_sfx_2: AudioStreamPlayer = $Sounds/shotSFX2



func _ready() -> void:
	health_handler.connect("hit", _on_hit)
	paths = $Paths.get_children()
	$spawnPart.emitting = true
	changeDir()
	makePath()
	for i in paths.size():
		paths[i].target_position = paths[i].target_position.rotated(deg_to_rad(i * (360/paths.size())))


func _physics_process(delta: float) -> void:
	center = player.current + player.screenSize * 0.5
	if not dead:
		await get_tree().create_timer(0.5).timeout
		movementDir = to_local(player.global_position).normalized()
		enemy_sprite.look_at(player.global_position)
		parry_tele.rotation = enemy_sprite.rotation
		if shot_cool.time_left <= 0 and not attacking:
			shot_cool.start()
		#checks for line of sight. if not, pathfind until line of sight is achieved, otherwise movetoward player
		if state == 1:
			if global_position.distance_to(player.global_position) < 120:
				findPath(180)
			else:
				findPath(0)
			
		velocity *= 0.85
		#outside of the line of sight code cause it has to override pathfinding
		if state == 2:
			velocity += dir * speed * 1.25 * delta
		move_and_slide()

func makePath():
	pathfinding.target_position = player.global_position

func shoot():
	shot_sfx.play()
	var energy = shot.instantiate()
	energy.type = 1
	energy.target = player
	energy.rotation = to_local((player.global_position + (player.velocity  * get_physics_process_delta_time() * (global_position.distance_to(player.global_position)/10)))).normalized().angle()
	energy.global_position = global_position
	get_tree().get_root().add_child(energy)
func shoot2():
	shotgun_sfx.play()
	for i in 7:
		var energy = shot.instantiate()
		energy.type = 3
		energy.target = player
		energy.rotation = to_local((player.global_position + (player.velocity * get_physics_process_delta_time() * (global_position.distance_to(player.global_position)/10)))).normalized().angle() + deg_to_rad(randf_range(-20, 20))
		energy.global_position = global_position
		get_tree().get_root().add_child(energy)
func shoot3():
	shot_sfx_2.play()
	var energy = shot.instantiate()
	energy.type = 4
	energy.target = player
	energy.rotation = enemy_sprite.rotation + deg_to_rad(randf_range(-7, 7))
	energy.global_position = global_position
	get_tree().get_root().add_child(energy)
func shoot4():
	shotgun_sfx.play()
	for i in 14:
		var energy = shot.instantiate()
		energy.type = 3
		energy.target = player
		energy.rotation = to_local((player.global_position + (player.velocity * get_physics_process_delta_time() * (global_position.distance_to(player.global_position)/11)))).normalized().angle() + deg_to_rad(randf_range(-40, 40))
		energy.global_position = global_position
		get_tree().get_root().add_child(energy)
		
func changeDir():
	state = 2
	dir = movementDir
	velocity = Vector2.ZERO
	await get_tree().create_timer(0.3).timeout
	if sideDir == 270:
		sideDir = 90
	else:
		sideDir = 270
	state = 1
	

func _on_sight_timer_timeout() -> void:
	makePath()

func _on_dir_timer_timeout() -> void:
	changeDir()
	dir_timer.start(randf_range(2, 3))


func _on_shot_cool_timeout() -> void:
	if dead == false:
		attacking = true
		num += 1
		if num == 3:
			full_charge.emitting = true
		var type = randi_range(1, 3)
		if num >= 4:
			type = 4
			num = 0
		if type == 1:
			parry_tele.restart()
			beep.play()
			for i in 5:
				await get_tree().create_timer(0.2).timeout
				if not dead:
					shoot()
		elif type == 2:
			parry_tele.restart()
			beep.play()
			await get_tree().create_timer(0.2).timeout
			shoot2()
		elif type == 3:
			unparry_tele.restart()
			beep.play()
			await get_tree().create_timer(0.2).timeout
			for i in 30:
				if not dead:
					await get_tree().create_timer(0.05).timeout
					shoot3()
		elif type == 4:
			parry_tele.restart()
			beep.play()
			await get_tree().create_timer(0.2).timeout
			for i in 4:
				shoot4()
				await get_tree().create_timer(0.2).timeout
				Signals.emit_signal("shakeSmall")
		full_charge.emitting = false
		attacking = false
func findPath(dir: float):
	var highest: choice
	for i in paths.size():
		paths[i].weight = cos(paths[i].target_position.normalized().angle_to(movementDir.rotated(deg_to_rad(dir))))
		paths[i].weight += cos(paths[i].target_position.normalized().angle_to(movementDir.rotated(deg_to_rad(sideDir))))
		paths[i].weight += cos(paths[i].target_position.normalized().angle_to(movementDir.rotated(to_local(center).angle())))
		if paths[i].is_colliding():
			if i - 1 >= 0:
				paths[i - 1].weight -= 3
			paths[i].weight -= 5
			if paths[i].get_collider() is v2:
				if paths[i].get_collider().sideDir == sideDir:
					if randi_range(0, 1) == 1:
						changeDir()
			if i + 1 < paths.size():
				paths[i + 1].weight -= 3
		if highest == null or paths[i].weight > highest.weight:
			highest = paths[i]
	velocity  += highest.target_position.normalized() * speed * get_physics_process_delta_time()

func _on_hit():
	if not hit:
		hit = true
		await get_tree().create_timer(0.5).timeout
		if sideDir == 270:
			sideDir = 90
		else:
			sideDir = 270
		hit = false
