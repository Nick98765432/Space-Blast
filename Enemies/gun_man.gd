extends CharacterBody2D
class_name v2

var dead = false
var attacking: bool = false
#movement
#used for dash
var isParryable: bool = false
var shot : PackedScene = preload("res://Enemies/attacks/enemy energy blast.tscn")
var last: int
@export var player: Player
@onready var pathfinding: NavigationAgent2D = $pathfinding
@onready var sight_timer: Timer = $sightTimer
@onready var enemy_sprite: Sprite2D = $enemySprite
@onready var dir_timer: Timer = $dirTimer
@onready var shot_cool: Timer = $shotCool
@onready var health_handler: healthHandler = $healthHandler
@onready var sounds: Node2D = $Sounds
@onready var attacks: AttacksComp = $Attacks
@onready var particles: Particles = $Particles
@onready var hitbox: Area2D = $hitbox
@onready var brain: v2Brain = $v2Brain


func _ready() -> void:
	particles.spawn_part.emitting = true


func _physics_process(delta: float) -> void:
	if not dead:
		await get_tree().create_timer(0.5).timeout
		enemy_sprite.look_at(player.global_position)
		particles.parry_tele.rotation = enemy_sprite.rotation
		if shot_cool.time_left <= 0 and not attacking:
			shot_cool.start()
		brain.move()
		move_and_slide()

func _on_shot_cool_timeout() -> void:
	if dead == false:
		attacking = true
		var type = randi_range(1, 3)
		if last != null:
			if type == last:
				type = randi_range(1, 3)
		last = type
		if type == 1:
			attacks.telegraph()
			for i in 3:
				await get_tree().create_timer(0.2).timeout
				if not dead:
					attacks.preSingleShot()
		elif type == 2:
			attacks.telegraph()
			await get_tree().create_timer(0.2).timeout
			attacks.preShotgun()
		elif type == 3:
			attacks.untelegraph()
			await get_tree().create_timer(0.2).timeout
			for i in 30:
				if not dead:
					await get_tree().create_timer(0.05).timeout
					attacks.fullAuto()
		attacking = false
