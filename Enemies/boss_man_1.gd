extends CharacterBody2D

var last: int
var dead = false
var speed = 1000
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



func _ready() -> void:
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
				combo.x = randi_range(1, 2)
				if combo.x == last and last:
					combo.x = randi_range(1, 2)
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
	await get_tree().create_timer(0.3).timeout
	if combo.x == 1:
		if combo.y == 0:
			dash(false)
			await get_tree().create_timer(1).timeout
			done()
			combo.y += 1
		if combo.y == 1:
			dash(true)
			await get_tree().create_timer(1).timeout
			done()
			combo.y += 1
		if combo.y == 2:
			combo = Vector2i(0, 0)
	if combo.x == 2:
		if combo.y == 0:
			parry_tele.restart()
			await get_tree().create_timer(0.2).timeout
			shotgun()
			combo.y += 1
		if combo.y == 1:
			dash(false)
			await get_tree().create_timer(1).timeout
			done()
			combo = Vector2i(0, 0)
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
				if parry:
					if i.parry:
						if isParryable:
							health_handler.parried()
							damageDone = true
					else:
						if not(damageDone):
							i.damage(35)
							damageDone = true
				else:
					if not(damageDone):
						i.damage(35)
						damageDone = true
					
			break
	

func dash(parriable):
	if parriable:
		parry_tele.restart()
	else:
		unparry_tele.restart()
	await get_tree().create_timer(0.3).timeout
	damageDone = false
	isAttacking = true
	isParryable = parriable
	attackDir = movementDir
	if not parriable:
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
	var orig = enemy_sprite.rotation_degrees
	for i in 7:
		enemy_sprite.rotation_degrees += randf_range(-20, 20)
		shoot(3)
		enemy_sprite.rotation_degrees = orig
