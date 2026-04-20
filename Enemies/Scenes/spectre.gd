extends CharacterBody2D

var dead = false
@onready var side_dash: Timer = $sideDash
@onready var shot_cool: Timer = $shotCool
@onready var enemy_sprite: Sprite2D = $enemySprite
@onready var attacks: AttacksComp = $Attacks
@onready var health_handler: healthHandler = $healthHandler
@onready var particles: Particles = $Particles
@onready var proj_brain: projBrain = $projBrain
@onready var sounds: Sounds = $Sounds
@onready var pathfinding_brain: pathfinding = $pathfindingBrain
@export var player: Player
@onready var phase_dash: phaseDash = $phaseDash


func _physics_process(delta: float) -> void:
	if not dead:
		await get_tree().create_timer(0.5).timeout
		enemy_sprite.look_at(player.global_position)
		if pathfinding_brain.lineOfSight():
			proj_brain.move()
			if shot_cool.time_left <= 0:
				if not player.targeted:
					shot_cool.start()
		else:
			pathfinding_brain.moveTowardsPath()
			velocity *= 0.85
		move_and_slide()


func _on_shot_cool_timeout() -> void:
	if dead == false:
		while player.targeted:
			await get_tree().create_timer(0.25).timeout
		player.targeted = true
		attacks.telegraph()
		await get_tree().create_timer(0.2).timeout
		phase_dash.dash(Vector2(cos(enemy_sprite.rotation), sin(enemy_sprite.rotation)))
		await get_tree().create_timer(0.35).timeout
		player.targeted = false
		attacks.preShotgun()
		enemy_sprite.look_at(player.global_position)



func _on_side_dash_timeout() -> void:
	if pathfinding_brain.lineOfSight():
		pass
