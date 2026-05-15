extends CharacterBody2D

var movementDir: Vector2

var rechargeTime: float = 1.7
var attackSpeed: float = 1

var currentAttack: int
var lastAttack: int

var dead = false
var attacking: bool = false

@export var player: Player

@onready var e_trail_spawner: explosionSpawner = $ETrailSpawner
@onready var enemy_sprite: Sprite2D = $enemySprite
@onready var sight_timer: Timer = $sightTimer
@onready var shot_cool: Timer = $shotCool
@onready var hitbox: Area2D = $hitbox
@onready var phase_dash: phaseDash = $phaseDash
@onready var sounds: Sounds = $Sounds
@onready var attacks: AttacksComp = $Attacks
@onready var particles: Particles = $Particles
@onready var brain: v2Brain = $v2Brain
@onready var health_handler: healthHandler = $healthHandler


func _ready() -> void:
	e_trail_spawner.findFrames(phase_dash.dashSpeed / 60)

func _physics_process(delta: float) -> void:
	if not dead:
		await get_tree().create_timer(0.5).timeout
		movementDir = to_local(player.global_position).normalized()
		if not attacks.isAttacking:
			enemy_sprite.look_at(player.global_position)
		particles.parry_tele.rotation = enemy_sprite.rotation
		if phase_dash.stamina > 0 and not attacking:
			attackPattern()
		if not phase_dash.isDashing:
			brain.move()
		move_and_slide()


func attackPattern():
	attacking = true
	while phase_dash.stamina > 0:
		attack()
		attackSpeed = waitTime()
		await get_tree().create_timer(attackSpeed).timeout
	attacking = false
	if phase_dash.stamina <= 0:
		recharge()

func recharge():
	await get_tree().create_timer(rechargeTime).timeout
	phase_dash.stamina = phase_dash.maxStamina

func attack():
	currentAttack = randi_range(0, 2)
	if lastAttack:
		if lastAttack == currentAttack:
			currentAttack = randi_range(0, 2)
	match currentAttack:
		0:
			e_trail_spawner.active = true
			predash()
			await get_tree().create_timer(phase_dash.dashDur).timeout
			e_trail_spawner.active = false
			await get_tree().create_timer(0.2).timeout
			attacks.dash(true, true)
			await get_tree().create_timer(0.65).timeout
			attacks.done()
		1:
			var shootTime: float = 0.5
			attacks.telegraph()
			await get_tree().create_timer(0.2).timeout
			enemy_sprite.rotate(deg_to_rad(40))
			for i in 2:
				attacks.shootSRocket()
				enemy_sprite.rotate(deg_to_rad(-80))
		2:
			await get_tree().create_timer(0.2).timeout
			dash()
			await get_tree().create_timer(phase_dash.dashDur).timeout
			attacks.telegraph()
			await get_tree().create_timer(0.22).timeout
			if phase_dash.stamina <= 0:
				phase_dash.stamina = 1
			phase_dash.dash(Vector2(cos(enemy_sprite.rotation), sin(enemy_sprite.rotation)))
			await get_tree().create_timer(phase_dash.dashDur + 0.15).timeout
			attacks.preShotgun()
	
	lastAttack = currentAttack
func dash():
	var pos: Vector2 = ((player.global_position - global_position) + Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * brain.distance).normalized()
	phase_dash.dash(pos)
	
func predash():
	var pos = to_local((player.global_position + (player.velocity * (global_position.distance_to(player.global_position)/(phase_dash.dashSpeed/60))))).normalized()
	phase_dash.dash(pos)

func waitTime():
	match currentAttack:
		0:
			return phase_dash.dashDur + 0.2 + 0.65 + 1
		1:
			return  0.2 + 1
		2: 
			return phase_dash.dashDur * 2 + 0.2  + 0.22 + 0.15 + 1
