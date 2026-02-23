extends CharacterBody2D

var dead = false
var speed = 1000
var movementDir
var pos: Vector2
@export var player: Node
@onready var pathfinding: NavigationAgent2D = $pathfinding
@onready var line_of_sight: RayCast2D = $lineOfSight
@onready var sight_timer: Timer = $sightTimer
@onready var enemy_sprite: Sprite2D = $enemySprite
@onready var attack_timer: Timer = $attackTimer
@onready var hitbox: Area2D = $hitbox
@onready var health_handler: Node2D = $healthHandler
@onready var particles: Particles = $Particles
@onready var attacks: AttacksComp = $Attacks
@onready var sounds: Sounds = $Sounds



func _ready() -> void:
	makePath()


func _physics_process(delta: float) -> void:
	if not dead:
		await get_tree().create_timer(0.5).timeout
		movementDir = to_local(player.global_position).normalized()
		if not attacks.isAttacking:
			enemy_sprite.look_at(player.global_position)
		line_of_sight.target_position = to_local(player.global_position)
		line_of_sight.force_raycast_update()
		#checks for line of sight. if not, pathfind until line of sight is achieved, otherwise movetoward player
		if line_of_sight.get_collider() == player:
			if global_position.distance_to(player.global_position) > 70:
				velocity += movementDir * speed * delta
			else:
				if attack_timer.time_left <= 0 and not(attacks.chosen):
					attacks.chosen = true
					attack_timer.start()
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
	if not dead:
		attacks.dash(false, false)
		await get_tree().create_timer(0.5).timeout
		attacks.done()
		attacks.comboDone()
	
	
