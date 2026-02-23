extends CharacterBody2D

var dead = false
var shot : PackedScene = preload("res://Enemies/attacks/enemy energy blast.tscn")
@export var player: Node
@onready var line_of_sight: RayCast2D = $lineOfSight
@onready var enemy_sprite: Sprite2D = $enemySprite
@onready var shot_cool: Timer = $shotCool
@onready var health_handler: healthHandler = $healthHandler
@onready var proj_brain: projBrain = $projBrain
@onready var pathfinding_brain: pathfinding = $pathfindingBrain
@onready var sounds: Sounds = $Sounds
@onready var attacks: AttacksComp = $Attacks
@onready var particles: Particles = $Particles





func _physics_process(delta: float) -> void:
	if not dead:
		await get_tree().create_timer(0.5).timeout
		enemy_sprite.look_at(player.global_position)
		line_of_sight.target_position = to_local(player.global_position)
		line_of_sight.force_raycast_update()
		#checks for line of sight. if not, pathfind until line of sight is achieved, otherwise movetoward player and retreat if too close in circle motion
		#delay in between so the enemy does just circle strafe
		if line_of_sight.get_collider() == player:
			if global_position.distance_to(player.global_position) > 100:
				if shot_cool.time_left <= 0:
					shot_cool.start()
			proj_brain.move()
		else:
			pathfinding_brain.moveTowardsPath()
			velocity *= 0.85
			move_and_slide()


func _on_shot_cool_timeout() -> void:
	if line_of_sight.get_collider() == player and dead == false:
		while player.targeted:
			await get_tree().create_timer(0.25).timeout
		player.targeted = true
		attacks.telegraph()
		await get_tree().create_timer(0.2).timeout
		player.targeted = false
		attacks.singleShot()
		
