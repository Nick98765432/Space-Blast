extends CharacterBody2D
class_name Player

const screenSize: Vector2 = Vector2(640, 360)
var dead
var damageMult: float = 1
var parryEnergy: float = 100
var health: float = 100
var speed: float = 3600
var parry: bool = false
var parryCooled: bool = true
var shotCooled: bool = true
var shotCooled2: bool = true
var shotCooled3: bool = true
var targeted: bool = false
var weapon: int = 1
var ammo: int = 30
var bossBarCount: int = 0
var parryHeal: float = 25
var enemyCount := 0
var encounter: Vector2i = Vector2i(0, 0) 
var dir
var blast: PackedScene = preload("res://Player/Energy Blast Player.tscn")
var resist = 0
var powerup = PlayerData.playerSuper
var beserkModifier = 0
var powerupMult = 1
var ableToShoot: bool = true
var isDashing: bool = false
var trailState: int = -1
var dashAgain: bool = true
var dashDir: Vector2
var dashSpeed = 35000
var direction: float
var current: Vector2
var keycards: Array = []
var dashes: int = 2
@onready var spawnLocation: Vector2 = global_position
@onready var parry_timer: Timer = $"parry timer"
@onready var shot_cooldown: Timer = $"Shot cooldown"
@onready var parry_particles: GPUParticles2D = $"parry particles"
@onready var wall_and_evir_collisons: CollisionShape2D = $"Wall and evir collisons"
@onready var parry_hurt_box: Area2D = $ParryHurtBox
@onready var shotgun_cooldown: Timer = $"Shotgun cooldown"
@onready var fullauto_cooldown: Timer = $"Fullauto cooldown"
@onready var fullauto_regain: Timer = $"Fullauto regain"
@onready var full_charge: GPUParticles2D = $fullCharge
@onready var switch_speed: Timer = $"Switch Speed"
@onready var health_bar: TextureProgressBar = $HealthBar
@onready var player_sprite: Sprite2D = $"Player sprite"
@onready var change_weap: AudioStreamPlayer = $Sounds/ChangeWeap
@onready var shotgun_sfx: AudioStreamPlayer = $Sounds/shotgunSFX
@onready var shoot_sfx: AudioStreamPlayer = $Sounds/shootSFX
@onready var shoot_sfx_2: AudioStreamPlayer = $Sounds/shootSFX2
@onready var parry_sfx: AudioStreamPlayer = $Sounds/parrySFX
@onready var dash_cool: Timer = $dashCool
@onready var dash_part: GPUParticles2D = $dashPart
@onready var dash_part_2: GPUParticles2D = $dashPart2
@onready var dash_part_3: GPUParticles2D = $dashPart3
@onready var dash_trail: Line2D = $dashTrail
@onready var glitch_effect: ColorRect = $glitchEffect






func _ready() -> void:
	await get_tree().create_timer(0.01).timeout
	Signals.emit_signal("change")
	full_charge.emitting = false
	dash_part.top_level = true


func _physics_process(delta: float) -> void:
	current = (global_position / screenSize).floor()
	health_bar.value = move_toward(health_bar.value, health, 7)
	if not dead:
		#damage mult for glass cannon
		PlayerData.mult = 1
		if PlayerData.playerUpgrades.has(1):
			PlayerData.mult = 2
		if PlayerData.playerUpgrades.has(2):
			PlayerData.mult += abs((health/100) - 1.0)
		if PlayerData.playerUpgrades.has(3):
			if health <= PlayerData.maxHealth/2:
				PlayerData.mult += 0.5
		#bullet direction
		dir = (get_global_mouse_position() - global_position).normalized()
		#cap health
		if health > PlayerData.maxHealth:
			health = PlayerData.maxHealth
		if health <= 0:
			dead = true
			parryEnergy = 0
			$Explode1.restart()
			$Explode2.restart()
			$"Player sprite".hide()
		if powerup != 0:
			if parryEnergy > 100:
				parryEnergy = 100
			if parryEnergy == 100:
				full_charge.emitting = true
			else:
				full_charge.emitting = false
		#movement
		velocity += Vector2(Input.get_action_strength("right") - Input.get_action_strength("left"), (Input.get_action_strength("down") - Input.get_action_strength("up"))).normalized() * delta * speed
		velocity *= 0.85
		if Input.is_action_just_pressed("dash"):
			dash()
		if isDashing:
			velocity = dashSpeed * dashDir * delta
			dash_trail.points[1] = global_position
		match trailState:
			0:
				dash_trail.width = lerpf(dash_trail.width, 15, 15 * delta)
			1:
				dash_trail.width = lerpf(dash_trail.width, 0.1, 15 * delta)
				if dash_trail.width < 3:
					dash_trail.hide()
					trailState = -1
		#parry code
		#parry colldown
		if parryCooled and Input.is_action_just_pressed("parry"):
			parry = true
			parry_particles.restart()
			parry_timer.start()
			parryCooled = false
			await get_tree().create_timer(1.2).timeout
			parryCooled = true
		#parry parrying
		if parry:
			player_sprite.rotate(deg_to_rad(360/(parry_timer.wait_time)))
			for i in parry_hurt_box.get_overlapping_areas():
				if i.is_in_group("enemyProj"):
					if i.ifParried == false and i.isParriable:
						Hitstops.shortHitstop()
						parry_sfx.play()
						i.parried()
						health += parryHeal
						parryEnergy += 30
						parryCooled = true
						ammo = 30
		else:
			player_sprite.look_at(get_global_mouse_position())
			player_sprite.rotation_degrees -= 90
			
		#shoot
		#checks for weapon type to shot correct shot
		if Input.is_action_pressed("shoot") and ableToShoot:
			if weapon == 1 and shotCooled:
				shoot(1, dir.angle())
				shoot_sfx.play()
				shotCooled = false
				shot_cooldown.start()
			if weapon == 2 and shotCooled2:
				for i in 8:
					shoot(2, dir.angle() + deg_to_rad(randf_range(-20, 20)))
				shotgun_sfx.play()
				shotCooled2 = false
				shotgun_cooldown.start()
			if weapon == 3 and shotCooled3 and ammo > 0:
				shoot(3, dir.angle() + deg_to_rad(randf_range(-7, 7)))
				shoot_sfx_2.play()
				shotCooled3 = false
				ammo -= 1
				fullauto_cooldown.start()
		#supers
		if powerup == 1:
			if Input.is_action_just_pressed("alt fire") and parryEnergy >= 100 and weapon != 3:
				if weapon == 1:
					Signals.emit_signal("shakeSmall")
					for i in 30:
						shoot(1, deg_to_rad(i * 24))
						shoot_sfx.play()
						await get_tree().create_timer(0.01).timeout
				if weapon == 2:
					tripleShotgun()
				parryEnergy = 0
		elif powerup == 2:
			if Input.is_action_just_pressed("alt fire") and parryEnergy >= 100 and $"beserk duration".time_left <= 0:
				resist = 0.15
				speed = 4800
				parryEnergy = 0
				damageMult = 2
				$"beserk duration".start(5 + beserkModifier)
		#change weapons
		if Input.is_action_just_pressed("shot"):
			switch(1)
		if Input.is_action_just_pressed("shotgun"):
			switch(2)
		if Input.is_action_just_pressed("fullAuto"):
			switch(3)
		move_and_slide()
	else:
		if Input.is_action_just_pressed("restart"):
			global_position = spawnLocation
			$"Player sprite".show()
			health = 100
			dead = false
			encounter.y = 0
			Signals.emit_signal("destroy")
			Signals.emit_signal("change")
	

func switch(switchTo):
	switch_speed.start()
	ableToShoot = false
	weapon = switchTo
	change_weap.play()
	if switchTo == 1:
		$"Single Switch particle".restart()
	elif switchTo == 2:
		$"Shotgun Switch particle".restart()
	elif switchTo == 3:
		$"Auto Switch particle3".restart()
	
func _on_parry_timer_timeout() -> void:
	parry = false

func _on_shot_cooldown_timeout() -> void:
	shotCooled = true


func _on_shotgun_cooldown_timeout() -> void:
	shotCooled2 = true


func _on_fullauto_cooldown_timeout() -> void:
	shotCooled3 = true


func _on_fullauto_regain_timeout() -> void:
	if (Input.is_action_pressed("shoot") == false and weapon == 3 and ammo < 30) or (weapon != 3 and ammo < 30):
		ammo += 1

func shoot(type, deg):
	var shot = blast.instantiate()
	shot.damageMult = damageMult * powerupMult * PlayerData.mult
	shot.player = $"."
	shot.type = type
	shot.rotation = deg
	shot.global_position = global_position
	get_tree().get_root().add_child(shot)
	
func tripleShotgun():
	Signals.emit_signal("shakeSmall")
	for a in 4:
		for i in 16:
			shoot(2, dir.angle() + deg_to_rad(randf_range(-40, 40)))
		shotgun_sfx.play()
		await get_tree().create_timer(0.2).timeout
		Signals.emit_signal("shakeSmall")

func damage(amount):
	health -= amount * (1 - resist)


func _on_beserk_duration_timeout() -> void:
	resist = 0
	damageMult = 1
	speed = 3600


func _on_switch_speed_timeout() -> void:
	ableToShoot = true
	
func dash():
	dash_part.global_position = global_position
	if dashes > 0 and dashAgain and not isDashing:
		var dir = Vector2(Input.get_action_strength("right") - Input.get_action_strength("left"), (Input.get_action_strength("down") - Input.get_action_strength("up"))).normalized()
		isDashing = true
		if not dir == Vector2(0, 0):
			dashDir = dir
		else:
			dashDir = Vector2(1, 0)
		dashes -= 1
		dash_part.restart()
		glitch()
		dash_part_3.restart()
		dash_trail.points[0] = global_position
		#dash_trail.show()
		trailState = 0
		await get_tree().create_timer(0.3).timeout
		trailState = 1
		dash_part_2.restart()
		glitchIn()
		isDashing = false
		if dashes <= 0:
			dashAgain = false
		if dash_cool.time_left <= 0:
			dash_cool.start()
		
func glitch():
	glitch_effect.material.set_shader_parameter("shake_rate", 1.0)
	await get_tree().create_timer(0.15).timeout
	player_sprite.hide()
	glitch_effect.material.set_shader_parameter("shake_rate", 0.0)

func glitchIn():
	glitch_effect.material.set_shader_parameter("shake_rate", 1.0)
	player_sprite.show()
	await get_tree().create_timer(0.1).timeout
	glitch_effect.material.set_shader_parameter("shake_rate", 0.0)

func _on_dash_cool_timeout() -> void:
	if dashes < 2:
		dashes += 1
		dash_cool.start()
	else:
		dashAgain = true
