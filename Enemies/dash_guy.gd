extends CharacterBody2D

var movement: bool = true
var dead = false
var attackType: int = 0
var sideDir: float
var movementDir
var attackDir
var pos: Vector2
@export var player: Player
@onready var sight_timer: Timer = $sightTimer
@onready var enemy_sprite: Sprite2D = $enemySprite
@onready var attack_timer: Timer = $attackTimer
@onready var hitbox: Area2D = $hitbox
@onready var health_handler: Node2D = $healthHandler
@onready var attacks: AttacksComp = $Attacks
@onready var particles: Particles = $Particles
@onready var sounds: Sounds = $Sounds
@onready var brain: v2Brain = $v2Brain
@onready var pathfinding_brain: pathfinding = $pathfindingBrain


func _physics_process(delta: float) -> void:
	if not dead:
		await get_tree().create_timer(0.5).timeout
		movementDir = to_local(player.global_position).normalized()
		if not attacks.isAttacking:
			enemy_sprite.look_at(player.global_position)
		#checks for line of sight. if not, pathfind until line of sight is achieved, otherwise movetoward player
		if pathfinding_brain.lineOfSight():
			if (not attacks.chosen) and (not player.targeted):
				attack_timer.start()
				attacks.chosen = true
				player.targeted = true
			if movement:
				brain.move()
			
		else:
			pathfinding_brain.moveTowardsPath()

		velocity *= 0.85
		move_and_slide()


func _on_attack_timer_timeout() -> void:
	movement = false
	player.targeted = false
	if global_position.distance_to(player.global_position) <= 160:
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
