extends CharacterBody2D

var last: int
var dead = false
var speed = 2000
var movementDir
var attackDir
var isParryable: bool = false
var isAttacking: bool = false
var damageDone: bool = false
var pos: Vector2
var attackType: int
var chosen: bool = false
var combo: Vector2i
var shot : PackedScene = preload("res://Enemies/attacks/enemy energy blast.tscn")
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
@onready var teleport: GPUParticles2D = $Teleport
@onready var dash_sfx: AudioStreamPlayer = $Sounds/dashSFX
@onready var shoot_sfx: AudioStreamPlayer = $Sounds/shootSFX
@onready var beep: AudioStreamPlayer = $Sounds/beep
@onready var teleport_sfx: AudioStreamPlayer = $Sounds/teleportSFX





func _ready() -> void:
	teleport.set_as_top_level(true)
	$spawnPart.emitting = true
	makePath()


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
			if not chosen:
				combo.x = randi_range(1, 4)
				if combo.x == last and last:
					combo.x = randi_range(1, 4)
				last = combo.x
				attack_timer.start()
				chosen = true
		else:
			enemy_sprite.look_at(pathfinding.get_next_path_position())
			var dir = to_local(pathfinding.get_next_path_position()).normalized()
			velocity += (speed) * dir * delta
			if global_position.distance_to(player.global_position) < 3:
				velocity += (speed) * dir * delta * 50
		#attack
		if isAttacking:
			#attack code
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
	#combos checks for type and cycles attacks
	# x controls which combo and y controls attack in each combo
	if combo.x == 1:
		if combo.y == 0:
			tele()
			await get_tree().create_timer(0.3).timeout
			dash(false, true)
			await get_tree().create_timer(0.65).timeout
			done()
			combo.y += 1
		if combo.y == 1:
			dash(false, false)
			await get_tree().create_timer(0.65).timeout
			done()
			combo.y += 1
		if combo.y == 2:
			tele()
			await get_tree().create_timer(0.3).timeout
			dash(true, true)
			await get_tree().create_timer(0.65).timeout
			done()
			combo = Vector2i(0, 0)

	if combo.x == 2:
		if combo.y == 0:
			tele()
			await get_tree().create_timer(0.3).timeout
			dash(true, true)
			await get_tree().create_timer(0.65).timeout
			done()
			combo.y += 1
		if combo.y == 1:
			await get_tree().create_timer(0.2).timeout
			dash(false, true)
			await get_tree().create_timer(1).timeout
			done()
			combo.y += 1
		if combo.y == 2:
			telegraph()
			await get_tree().create_timer(0.2).timeout
			shotgun()
			await get_tree().create_timer(0.2).timeout
			combo = Vector2i(0, 0)

	if combo.x == 3:
		if combo.y == 0:
			dash(false, true)
			keepTele(0.7)
			await get_tree().create_timer(1.5).timeout
			done()
			combo = Vector2i(0, 0) 

	if combo.x == 4:
		if combo.y == 0:
			dash(true, true)
			await get_tree().create_timer(1).timeout
			done()
			combo.y += 1
		if combo.y == 1:
			telegraph()
			await get_tree().create_timer(0.2).timeout
			shotgun()
			await get_tree().create_timer(0.2).timeout
			combo = Vector2i(0, 0)
	#ending stuff
	pos = player.global_position
	isAttacking = false
	isParryable = false
	chosen = false

func attack(parry):
	velocity = attackDir * 36000 * 0.016667
	enemy_sprite.look_at(to_global(velocity))
	for i in hitbox.get_overlapping_bodies():
		if i is Player:
			if not dead:
				if i.parry:
					if isParryable:
						health_handler.parried()
						damageDone = true
				else:
					if not(damageDone):
						i.damage(35)
						damageDone = true
					
			break
	

func dash(parriable, predict):
	if parriable:
		telegraph()
	else:
		untelegraph()
	await get_tree().create_timer(0.1).timeout
	dash_sfx.play()
	damageDone = false
	isAttacking = true
	isParryable = parriable
	attackDir = movementDir
	if predict:
		attackDir = to_local((player.global_position + (player.velocity * (global_position.distance_to(player.global_position)/600)))).normalized()
	if parriable:
		attackType = 1
	else:
		attackType = 2

func done():
	isParryable = false
	isAttacking = false
	damageDone = false
	
func shoot(type):
	if not dead:
		var energy = shot.instantiate()
		energy.type = type
		energy.target = player
		energy.rotation = enemy_sprite.rotation
		energy.global_position = global_position
		get_tree().get_root().add_child(energy)
		
func shotgun():
	shoot_sfx.play()
	var orig = enemy_sprite.rotation_degrees
	for i in 8:
		enemy_sprite.rotation_degrees += randf_range(-20, 20)
		shoot(3)
		enemy_sprite.rotation_degrees = orig
		
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

func keepTele(time: float):
	var pos = global_position
	await get_tree().create_timer(time).timeout
	teleport_sfx.play()
	telePart()
	global_position = pos
	damageDone = false
	isParryable = true
	telegraph()
	attackDir = to_local((player.global_position + (player.velocity * (global_position.distance_to(player.global_position)/600)))).normalized()

func untelegraph():
	unparry_tele.restart()
	beep.play()

func telegraph():
	parry_tele.restart()
	beep.play()
