extends Node2D
class_name AttacksComp

var attackDir
var isParryable: bool = false
var damageDone: bool = false
var isAttacking: bool = false
var chosen: bool = false
var attackType: int
var shot : PackedScene = preload("res://Enemies/attacks/enemy energy blast.tscn")
var parent := get_parent()
var sounds: Sounds
var particles: Particles
var player: Player

func _ready() -> void:
	await get_tree().create_timer(0.01).timeout
	parent = get_parent()
	sounds = parent.sounds
	particles = parent.particles
	player = parent.player
	print(get_parent().particles)

func _physics_process(delta: float) -> void:
	if isAttacking:
		#attack code
		if attackType == 1:
			attack(true)
		elif attackType == 2:
			attack(false)

func attack(parry):
	parent.velocity = attackDir * 36000 * 0.016667
	parent.enemy_sprite.look_at(parent.to_global(parent.velocity))
	for i in parent.hitbox.get_overlapping_bodies():
		if i is Player:
			if not parent.dead:
				if i.parry:
					if isParryable:
						parent.health_handler.parried()
						damageDone = true
				else:
					if not(damageDone):
						i.damage(35)
						damageDone = true
					
			break

func done():
	isParryable = false
	isAttacking = false
	damageDone = false
	
func comboDone():
	parent.pos = player.global_position
	isAttacking = false
	isParryable = false
	chosen = false

func dash(parriable, predict):
	if parriable:
		telegraph()
	else:
		untelegraph()
	await get_tree().create_timer(0.1).timeout
	sounds.dash_sfx.play()
	damageDone = false
	isAttacking = true
	isParryable = parriable
	attackDir = parent.movementDir
	if predict:
		attackDir = parent.to_local((player.global_position + (player.velocity * (parent.global_position.distance_to(player.global_position)/600)))).normalized()
	if parriable:
		attackType = 1
	else:
		attackType = 2

func shoot(type):
	if not parent.dead:
		var energy = shot.instantiate()
		energy.type = type
		energy.target = player
		energy.rotation = parent.enemy_sprite.rotation
		energy.global_position = parent.global_position
		get_tree().get_root().add_child(energy)

func preShoot(type):
	var energy = shot.instantiate()
	energy.type = type
	energy.target = player
	energy.rotation = to_local((player.global_position + (player.velocity  * get_physics_process_delta_time() * (parent.global_position.distance_to(player.global_position)/10)))).normalized().angle()
	if type == 3:
		energy.rotation_degrees += randf_range(-20, 20)
	energy.global_position = parent.global_position
	get_tree().get_root().add_child(energy)

func preSingleShot():
	preShoot(1)
	sounds.shot_sfx.play()

func shotgun():
	sounds.shotgun_sfx.play()
	var orig = parent.enemy_sprite.rotation_degrees
	for i in 8:
		parent.enemy_sprite.rotation_degrees += randf_range(-20, 20)
		shoot(3)
		parent.enemy_sprite.rotation_degrees = orig

func preShotgun():
	sounds.shotgun_sfx.play()
	var orig = parent.enemy_sprite.rotation_degrees
	for i in 8:
		parent.enemy_sprite.rotation_degrees += randf_range(-20, 20)
		preShoot(3)
		parent.enemy_sprite.rotation_degrees = orig

func fullAuto():
	sounds.fullauto_sfx.play()
	var energy = shot.instantiate()
	energy.type = 4
	energy.target = player
	energy.rotation = parent.enemy_sprite.rotation + deg_to_rad(randf_range(-7, 7))
	energy.global_position = parent.global_position
	get_tree().get_root().add_child(energy)

func telePart():
	particles.teleport.global_position = parent.global_position
	particles.teleport.process_material.angle_min = -parent.enemy_sprite.rotation_degrees
	particles.teleport.process_material.angle_max = -parent.enemy_sprite.rotation_degrees
	particles.teleport.restart()

func tele():
	telePart()
	sounds.teleport_sfx.play()
	parent.global_position = player.global_position
	parent.enemy_sprite.rotation_degrees = randf_range(-180, 180)
	parent.velocity = parent.enemy_sprite.transform.x * 6000
	parent.move_and_slide()
	parent.velocity = Vector2.ZERO

func keepTele(time: float):
	var pos = parent.global_position
	await get_tree().create_timer(time).timeout
	sounds.teleport_sfx.play()
	telePart()
	parent.global_position = pos
	damageDone = false
	isParryable = true
	telegraph()
	attackDir = parent.to_local((player.global_position + (player.velocity * (parent.global_position.distance_to(player.global_position)/600)))).normalized()

func untelegraph():
	particles.unparry_tele.restart()
	sounds.beep.play()

func telegraph():
	particles.parry_tele.restart()
	sounds.beep.play()

	
