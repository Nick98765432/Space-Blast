extends CharacterBody2D

var dead = false
var speed = 1000
var sideDir: float
var movementDir
var attackDir
var isParryable: bool = false
var isAttacking: bool = false
var damageDone: bool = false
var pos: Vector2
var attackType: int
var chosen: bool = false
@export var player: Player
@onready var pathfinding: NavigationAgent2D = $pathfinding
@onready var line_of_sight: RayCast2D = $lineOfSight
@onready var sight_timer: Timer = $sightTimer
@onready var enemy_sprite: Sprite2D = $enemySprite
@onready var parry_tele: GPUParticles2D = $parryTele
@onready var unparry_tele: GPUParticles2D = $unparryTele
@onready var attack_timer: Timer = $attackTimer
@onready var hitbox: Area2D = $hitbox
@onready var health_handler: Node2D = $healthHandler
@onready var dash_sfx: AudioStreamPlayer = $Sounds/dashSFX
@onready var beep: AudioStreamPlayer = $Sounds/beep



func _ready() -> void:
	$spawnPart.emitting = true
	makePath()
	changeDir()


func _physics_process(delta: float) -> void:
	if not dead:
		await get_tree().create_timer(0.5).timeout
		movementDir = to_local(player.global_position).normalized()
		enemy_sprite.look_at(player.global_position)
		parry_tele.rotation = enemy_sprite.rotation
		unparry_tele.rotation = enemy_sprite.rotation
		line_of_sight.target_position = to_local(player.global_position)
		line_of_sight.force_raycast_update()
		#checks for line of sight. if not, pathfind until line of sight is achieved, otherwise movetoward player
		if line_of_sight.get_collider() == player:
			if attack_timer.time_left <= 0 and not(isAttacking) and not(chosen) and (not player.targeted):
				chosen = true
				player.targeted = true
				await get_tree().create_timer(0.5).timeout
				if (not dead):
					attack_timer.start()
					if global_position.distance_to(player.global_position) <= 150:
						parry_tele.restart()
						attackType = 1
					else:
						unparry_tele.restart()
						attackType = 2
					beep.play()
			else:
				velocity += -enemy_sprite.transform.x * speed * delta
				velocity += enemy_sprite.transform.x.rotated(deg_to_rad(sideDir)) * speed * delta
			
		else:
			enemy_sprite.look_at(pathfinding.get_next_path_position())
			var dir = to_local(pathfinding.get_next_path_position()).normalized()
			velocity += (speed) * dir * delta
		#attack
		if isAttacking:
			#attack code for the acutal dash
			if attackType == 1:
				attack(true)
			elif attackType == 2:
				attack(false)

		velocity *= 0.85
		move_and_slide()

func makePath():
	pathfinding.target_position = player.global_position

func _on_sight_timer_timeout() -> void:
	makePath()

func _on_attack_timer_timeout() -> void:
	#acutal attack
	player.targeted = false
	isAttacking = true
	damageDone = false
	isParryable = true
	attackDir = movementDir
	pos = player.global_position
	dash_sfx.play()
	#signals to attack in process and turns it off after timer
	if attackType == 1:
		await get_tree().create_timer(0.5).timeout
	if attackType == 2:
		await get_tree().create_timer(1).timeout
	chosen = false
	changeDir()
	isAttacking = false
	isParryable = false

func attack(parry):
	#tells how to dash
	velocity = attackDir * 24000 * 0.016667
	enemy_sprite.look_at(to_global(velocity))
	for i in hitbox.get_overlapping_bodies():
		if i is Player:
			if not dead:
				if parry:
					if i.parry:
						if isParryable:
							health_handler.parried()
							damageDone = true
					else:
						if not(damageDone):
							i.damage(30)
							damageDone = true
				else:
					if not(damageDone):
						i.damage(30)
						damageDone = true
					
			break
	
func changeDir():
	if randi_range(0, 1) == 1:
		sideDir = 90
	else:
		sideDir = 270
