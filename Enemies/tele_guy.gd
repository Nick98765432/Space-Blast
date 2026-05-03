extends CharacterBody2D

var dead = false
@export var player: Player
@onready var enemy_sprite: Sprite2D = $enemySprite
@onready var shot_cool: Timer = $shotCool
@onready var health_handler: healthHandler = $healthHandler
@onready var sounds: Sounds = $Sounds
@onready var particles: Particles = $Particles
@onready var attacks: AttacksComp = $Attacks
@onready var proj_brain: projBrain = $projBrain
@onready var death_beam: beamRay = $deathBeam



func _physics_process(delta: float) -> void:
	if not dead:
		await get_tree().create_timer(0.5).timeout
		enemy_sprite.look_at(player.global_position)
		#shoots at player and moves to it. no pathfinding needed cause teleports
		if shot_cool.time_left <= 0:
			if not player.targeted:
				shot_cool.start()
		proj_brain.move()
		move_and_slide()




func _on_shot_cool_timeout() -> void:
	if dead == false:
		while player.targeted:
			await get_tree().create_timer(0.25).timeout
		var attack = randi_range(0, 1)
		player.targeted = true
		if attack == 1:
			attacks.telegraph()
		else:
			attacks.untelegraph()
		await get_tree().create_timer(0.2).timeout
		player.targeted = false
		if attack == 1:
			attacks.tele()
			await get_tree().create_timer(0.5).timeout
			attacks.shootSRocket()
			enemy_sprite.rotate(deg_to_rad(45))
			for i in 2:
				attacks.shootSRocket()
				enemy_sprite.rotate(deg_to_rad(-90))
		else:
				attacks.shootRocket()
		enemy_sprite.look_at(player.global_position)
		


		
