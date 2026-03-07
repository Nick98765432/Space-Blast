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



func _physics_process(delta: float) -> void:
	if not dead:
		await get_tree().create_timer(0.5).timeout
		enemy_sprite.look_at(player.global_position)
		#shoots at player and moves to it. no pathfinding needed cause teleports
		if shot_cool.time_left <= 0:
			shot_cool.start()
		proj_brain.move()
		move_and_slide()




func _on_shot_cool_timeout() -> void:
	if dead == false:
		while player.targeted:
			await get_tree().create_timer(0.25).timeout
		player.targeted = true
		attacks.telegraph()
		await get_tree().create_timer(0.2).timeout
		player.targeted = false
		if randi_range(0, 1) == 1:
			attacks.tele()
			await get_tree().create_timer(0.5).timeout
		attacks.homingShot()
		enemy_sprite.rotate(deg_to_rad(45))
		for i in 2:
			attacks.homingShot()
			enemy_sprite.rotate(deg_to_rad(-90))
		enemy_sprite.look_at(player.global_position)
		


		
