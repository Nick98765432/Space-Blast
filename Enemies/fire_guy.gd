extends CharacterBody2D

var dead = false
var speed = 1000
var movementDir
var attackDir
var isParryable: bool = false
var isAttacking: bool = false
var pos: Vector2
@export var player: Player
@onready var pathfinding: NavigationAgent2D = $pathfinding
@onready var line_of_sight: RayCast2D = $lineOfSight
@onready var sight_timer: Timer = $sightTimer
@onready var enemy_sprite: Sprite2D = $enemySprite
@onready var parry_tele: GPUParticles2D = $parryTele
@onready var attack_timer: Timer = $attackTimer
@onready var hitbox: Area2D = $hitbox
@onready var health_handler: Node2D = $healthHandler
@onready var fire: GPUParticles2D = $Fire
@onready var hurtbox_fire: Area2D = $HurtboxFire
@onready var beep: AudioStreamPlayer = $Sounds/beep
@onready var burn: AudioStreamPlayer = $Sounds/burn



func _ready() -> void:
	$spawnPart.emitting = true
	makePath()


func _physics_process(delta: float) -> void:
	if dead:
		fire.emitting = false
	if not dead:
		await get_tree().create_timer(0.5).timeout
		#makes sure everything is aligned to the player
		movementDir = to_local(player.global_position).normalized()
		enemy_sprite.look_at(player.global_position)
		hurtbox_fire.look_at(player.global_position)
		fire.look_at(player.global_position)
		parry_tele.rotation = enemy_sprite.rotation
		line_of_sight.target_position = to_local(player.global_position)
		line_of_sight.force_raycast_update()
		#checks for line of sight. if not, pathfind until line of sight is achieved, otherwise movetoward player
		if line_of_sight.get_collider() == player:
			if global_position.distance_to(player.global_position) > 40:
				velocity += movementDir * speed * delta
			if attack_timer.time_left <= 0 and not(isAttacking) and global_position.distance_to(player.global_position) < 120:
				attack_timer.start()
				parry_tele.restart()
				beep.play()
			
		else:
			enemy_sprite.look_at(pathfinding.get_next_path_position())
			var dir = to_local(pathfinding.get_next_path_position()).normalized()
			velocity += (speed) * dir * delta
		#attack
		if isAttacking:
			#parrible
			for i in hurtbox_fire.get_overlapping_bodies():
				if i is Player:
					if not dead:
						player.damage(0.7)
					break
		velocity *= 0.85
		move_and_slide()

func makePath():
	pathfinding.target_position = player.global_position

func _on_sight_timer_timeout() -> void:
	makePath()

func _on_attack_timer_timeout() -> void:
	isAttacking = true
	fire.emitting = true
	burn.play()
	attackDir = movementDir
	pos = player.global_position
	await get_tree().create_timer(1.5).timeout
	burn.stop()
	isAttacking = false
	isParryable = false
	fire.emitting = false
	
	
	
