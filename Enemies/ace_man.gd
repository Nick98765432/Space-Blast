extends CharacterBody2D

var last: int
var dead = false
var movementDir
var pos: Vector2
var combo: Vector2i
@export var player: Player
@onready var enemy_sprite: Sprite2D = $enemySprite
@onready var attack_timer: Timer = $attackTimer
@onready var hitbox: Area2D = $hitbox
@onready var health_handler: Node2D = $healthHandler
@onready var attacks: AttacksComp = $Attacks
@onready var sounds: Sounds = $Sounds
@onready var particles: Particles = $Particles
@onready var pathfinding_brain: pathfinding = $pathfindingBrain
@onready var v_2_brain: v2Brain = $v2Brain


func _physics_process(delta: float) -> void:
	if not dead:
		await get_tree().create_timer(0.5).timeout
		movementDir = to_local(player.global_position).normalized()
		if not attacks.isAttacking:
			enemy_sprite.look_at(player.global_position)
		#checks for line of sight. if not, pathfind until line of sight is achieved, otherwise movetoward player
		if pathfinding_brain.lineOfSight():
			v_2_brain.move()
			if not attacks.chosen:
				combo.x = randi_range(1, 4)
				if combo.x == last and last:
					combo.x = randi_range(1, 4)
				last = combo.x
				attack_timer.start()
				attacks.chosen = true
		else:
			pathfinding_brain.moveTowardsPath()
		velocity *= 0.85
		move_and_slide()

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
