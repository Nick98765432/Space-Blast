extends CharacterBody2D

var last: int
var dead = false
var speed = 2000
var movementDir
var pos: Vector2
var combo: Vector2i
@export var player: Player
@onready var pathfinding: NavigationAgent2D = $pathfinding
@onready var line_of_sight: RayCast2D = $lineOfSight
@onready var sight_timer: Timer = $sightTimer
@onready var enemy_sprite: Sprite2D = $enemySprite
@onready var attack_timer: Timer = $attackTimer
@onready var hitbox: Area2D = $hitbox
@onready var health_handler: Node2D = $healthHandler
@onready var attacks: AttacksComp = $Attacks
@onready var sounds: Sounds = $Sounds
@onready var particles: Particles = $Particles




func _ready() -> void:
	particles.teleport.set_as_top_level(true)
	particles.spawn_part.emitting = true
	makePath()


func _physics_process(delta: float) -> void:
	if not dead:
		await get_tree().create_timer(0.5).timeout
		movementDir = to_local(player.global_position).normalized()
		if not attacks.isAttacking:
			enemy_sprite.look_at(player.global_position)
		particles.parry_tele.rotation = enemy_sprite.rotation
		particles.unparry_tele.rotation = enemy_sprite.rotation
		line_of_sight.target_position = to_local(player.global_position)
		line_of_sight.force_raycast_update()
		#checks for line of sight. if not, pathfind until line of sight is achieved, otherwise movetoward player
		if line_of_sight.get_collider() == player:
			if not attacks.chosen:
				combo.x = randi_range(1, 4)
				if combo.x == last and last:
					combo.x = randi_range(1, 4)
				last = combo.x
				attack_timer.start()
				attacks.chosen = true
		else:
			enemy_sprite.look_at(pathfinding.get_next_path_position())
			var dir = to_local(pathfinding.get_next_path_position()).normalized()
			velocity += (speed) * dir * delta
			if global_position.distance_to(player.global_position) < 3:
				velocity += (speed) * dir * delta * 50
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
			attacks.tele()
			await get_tree().create_timer(0.3).timeout
			attacks.dash(false, true)
			await get_tree().create_timer(0.65).timeout
			attacks.done()
			combo.y += 1
		if combo.y == 1:
			attacks.dash(false, false)
			await get_tree().create_timer(0.65).timeout
			attacks.done()
			combo.y += 1
		if combo.y == 2:
			attacks.tele()
			await get_tree().create_timer(0.3).timeout
			attacks.dash(true, true)
			await get_tree().create_timer(0.65).timeout
			attacks.done()
			combo = Vector2i(0, 0)

	if combo.x == 2:
		if combo.y == 0:
			attacks.tele()
			await get_tree().create_timer(0.3).timeout
			attacks.dash(true, true)
			await get_tree().create_timer(0.65).timeout
			attacks.done()
			combo.y += 1
		if combo.y == 1:
			await get_tree().create_timer(0.2).timeout
			attacks.dash(false, true)
			await get_tree().create_timer(1).timeout
			attacks.done()
			combo.y += 1
		if combo.y == 2:
			attacks.telegraph()
			await get_tree().create_timer(0.2).timeout
			attacks.shotgun()
			await get_tree().create_timer(0.2).timeout
			combo = Vector2i(0, 0)

	if combo.x == 3:
		if combo.y == 0:
			attacks.dash(false, true)
			attacks.keepTele(0.7)
			await get_tree().create_timer(1.5).timeout
			attacks.done()
			combo = Vector2i(0, 0) 

	if combo.x == 4:
		if combo.y == 0:
			attacks.dash(true, true)
			await get_tree().create_timer(1).timeout
			attacks.done()
			combo.y += 1
		if combo.y == 1:
			attacks.telegraph()
			await get_tree().create_timer(0.2).timeout
			attacks.shotgun()
			await get_tree().create_timer(0.2).timeout
			combo = Vector2i(0, 0)
	#ending stuff
	attacks.comboDone()
