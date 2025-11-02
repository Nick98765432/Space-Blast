extends CharacterBody2D

var dead = false
var started = false
var speed = 500
var movementDir
var sideDir = 90
var state = 1
var isParryable: bool = false
var shot : PackedScene = preload("res://Enemies/attacks/enemy energy blast.tscn")
var attacking: bool = false
@export var player: Player
@onready var pathfinding: NavigationAgent2D = $pathfinding
@onready var line_of_sight: RayCast2D = $lineOfSight
@onready var sight_timer: Timer = $sightTimer
@onready var enemy_sprite: Sprite2D = $enemySprite
@onready var dir_timer: Timer = $dirTimer
@onready var shot_cool: Timer = $shotCool
@onready var parry_tele: GPUParticles2D = $parryTele
@onready var health_handler: healthHandler = $healthHandler
@onready var fire_rate: Timer = $fireRate
@onready var beep: AudioStreamPlayer = $Sounds/Beep
@onready var shoot_sfx: AudioStreamPlayer = $Sounds/shootSFX



func _ready() -> void:
	$spawnPart.emitting = true
	changeDir()
	makePath()


func _physics_process(delta: float) -> void:
	if not dead:
		await get_tree().create_timer(0.5).timeout
		movementDir = to_local(player.global_position).normalized()
		enemy_sprite.look_at(player.global_position)
		parry_tele.rotation = enemy_sprite.rotation
		line_of_sight.target_position = to_local(player.global_position)
		line_of_sight.force_raycast_update()
		#checks for line of sight. if not, pathfind until line of sight is achieved, otherwise movetoward player and retreat if too close in circle motion
		#delay in between so the enemy does just circle strafe
		if line_of_sight.get_collider() == player:
			if global_position.distance_to(player.global_position) > 100:
				if shot_cool.time_left <= 0 and not attacking and not started:
					shot_cool.start()
					started = true
					await get_tree().create_timer(1.7).timeout
					attacking = true
					started = false
			if state == 1:
				velocity += movementDir * speed * delta
				if global_position.distance_to(player.global_position) < 100:
					if $stateChange.time_left <= 0:
						$stateChange.start()
			if state == 2:
				velocity -= movementDir * speed * delta
				velocity += (movementDir * speed * delta).rotated(deg_to_rad(sideDir))
				if global_position.distance_to(player.global_position) > 100:
					if $stateChange.time_left <= 0:
						$stateChange.start()
		else:
			enemy_sprite.look_at(pathfinding.get_next_path_position())
			var dir = to_local(pathfinding.get_next_path_position()).normalized()
			velocity += (speed) * dir * delta
			if global_position.distance_to(player.global_position) < 3:
				velocity += (speed) * dir * delta * 50
		if attacking:
			if fire_rate.time_left <= 0:
				fire_rate.start()
			
		velocity *= 0.85
		move_and_slide()

func makePath():
	pathfinding.target_position = player.global_position

func shoot():
	var energy = shot.instantiate()
	shoot_sfx.play()
	energy.type = 4
	energy.target = player
	energy.rotation = enemy_sprite.rotation + deg_to_rad(randf_range(-7, 7))
	energy.global_position = global_position
	get_tree().get_root().add_child(energy)

func changeDir():
	if randi_range(0,1) == 0:
		sideDir = 90
	else:
		sideDir = 270

func _on_sight_timer_timeout() -> void:
	makePath()

func _on_dir_timer_timeout() -> void:
	changeDir()

func _on_state_change_timeout() -> void:
	if state == 1:
		if global_position.distance_to(player.global_position) < 100:
			state = 2
	if state == 2:
		if global_position.distance_to(player.global_position) > 100:
			state = 1

func _on_shot_cool_timeout() -> void:
	if line_of_sight.get_collider() == player and dead == false:
		parry_tele.emitting = true
		beep.play()
		await get_tree().create_timer(2).timeout
		attacking = false

		


func _on_fire_rate_timeout() -> void:
	if not dead:
		shoot()
