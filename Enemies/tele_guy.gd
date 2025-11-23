extends CharacterBody2D

var dead = false
var speed = 500
var movementDir
var sideDir = 90
var state = 1
var isParryable: bool = false
var shot : PackedScene = preload("res://Enemies/attacks/enemy energy blast.tscn")
@export var player: Player
@onready var enemy_sprite: Sprite2D = $enemySprite
@onready var dir_timer: Timer = $dirTimer
@onready var shot_cool: Timer = $shotCool
@onready var parry_tele: GPUParticles2D = $parryTele
@onready var health_handler: healthHandler = $healthHandler
@onready var teleport: GPUParticles2D = $Teleport
@onready var beep: AudioStreamPlayer = $Sounds/beep
@onready var shoot_sfx: AudioStreamPlayer = $Sounds/shootSFX
@onready var teleport_sfx: AudioStreamPlayer = $Sounds/teleportSFX



func _ready() -> void:
	$spawnPart.emitting = true
	teleport.set_as_top_level(true)
	changeDir()


func _physics_process(delta: float) -> void:
	if not dead:
		await get_tree().create_timer(0.5).timeout
		movementDir = to_local(player.global_position).normalized()
		enemy_sprite.look_at(player.global_position)
		parry_tele.rotation = enemy_sprite.rotation
		#shoots at player and moves to it. no pathfinding needed cause teleports
		if shot_cool.time_left <= 0:
			shot_cool.start()
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
			
		velocity *= 0.85
		move_and_slide()


func shoot(type):
	if not dead:
		var energy = shot.instantiate()
		energy.type = type
		energy.target = player
		energy.rotation = enemy_sprite.rotation
		energy.global_position = global_position
		get_tree().get_root().add_child(energy)

func changeDir():
	if randi_range(0,1) == 0:
		sideDir = 90
	else:
		sideDir = 270

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
	if dead == false:
		while player.targeted:
			await get_tree().create_timer(0.25).timeout
		player.targeted = true
		parry_tele.restart()
		beep.play()
		await get_tree().create_timer(0.2).timeout
		player.targeted = false
		if randi_range(0, 1) == 1:
			tele()
			await get_tree().create_timer(0.5).timeout
		shoot(2)
		enemy_sprite.rotate(deg_to_rad(45))
		for i in 2:
			shoot(1)
			enemy_sprite.rotate(deg_to_rad(-90))
		shoot_sfx.play()
		enemy_sprite.look_at(player.global_position)
		

func telePart():
	teleport.global_position = global_position
	teleport.process_material.angle_min = -enemy_sprite.rotation_degrees
	teleport.process_material.angle_max = -enemy_sprite.rotation_degrees
	teleport.restart()

func tele():
	telePart()
	teleport_sfx.play()
	global_position = player.global_position
	enemy_sprite.rotation_degrees = randf_range(-180, 180)
	velocity = enemy_sprite.transform.x * 6000
	move_and_slide()
	velocity = Vector2.ZERO

		
