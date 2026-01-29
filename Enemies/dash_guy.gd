extends CharacterBody2D

var movement: bool = true
var dead = false
var attackType: int = 0
var speed = 1000
var sideDir: float
var movementDir
var attackDir
var pos: Vector2
@export var player: Player
@onready var pathfinding: NavigationAgent2D = $pathfinding
@onready var line_of_sight: RayCast2D = $lineOfSight
@onready var sight_timer: Timer = $sightTimer
@onready var enemy_sprite: Sprite2D = $enemySprite
@onready var attack_timer: Timer = $attackTimer
@onready var hitbox: Area2D = $hitbox
@onready var health_handler: Node2D = $healthHandler
@onready var attacks: AttacksComp = $Attacks
@onready var particles: Particles = $Particles
@onready var sounds: Sounds = $Sounds
@onready var brain: v2Brain = $v2Brain


func _ready() -> void:
	particles.spawn_part.emitting = true
	makePath()



func _physics_process(delta: float) -> void:
	if not dead:
		await get_tree().create_timer(0.5).timeout
		movementDir = to_local(player.global_position).normalized()
		particles.parry_tele.rotation = enemy_sprite.rotation
		particles.unparry_tele.rotation = enemy_sprite.rotation
		line_of_sight.target_position = to_local(player.global_position)
		line_of_sight.force_raycast_update()
		if not attacks.isAttacking:
			enemy_sprite.look_at(player.global_position)
		#checks for line of sight. if not, pathfind until line of sight is achieved, otherwise movetoward player
		if line_of_sight.get_collider() == player:
			if (not attacks.chosen) and (not player.targeted):
				attack_timer.start()
				attacks.chosen = true
				player.targeted = true
			if movement:
				brain.move()
			
		else:
			enemy_sprite.look_at(pathfinding.get_next_path_position())
			var dir = to_local(pathfinding.get_next_path_position()).normalized()
			velocity += (speed) * dir * delta

		velocity *= 0.85
		move_and_slide()

func makePath():
	pathfinding.target_position = player.global_position

func _on_sight_timer_timeout() -> void:
	makePath()

func _on_attack_timer_timeout() -> void:
	movement = false
	player.targeted = false
	if global_position.distance_to(player.global_position) <= 150:
		attackType = 1
	else:
		attackType = 2
	if attackType == 1:
		attacks.dash(true, false)
		await get_tree().create_timer(0.5).timeout
	elif attackType == 2:
		attacks.dash(false, false)
		await get_tree().create_timer(0.7).timeout
	movement = true
	attacks.done()
	await get_tree().create_timer(randf_range(0.3,0.4)).timeout
	attacks.comboDone()
