extends Node2D
class_name healthHandler
signal hit

var player: Player
var energyGiven = false
@onready var parent: Node = $".."
@export var isBoss: bool
@export var health: float
@export var bossBar: TextureProgressBar

func _ready() -> void:
	await get_tree().create_timer(0.001).timeout
	Signals.connect("bossDeath", _on_death)
	player = parent.player
	player.enemyCount += 1
	Signals.connect("destroy", _on_destroy)
	if isBoss:
		bossBar.max_value = health
		bossBar.value = health
		bossBar.show()
		bossBar.position = Vector2(15, player.bossBarCount * (15 + 32) + 15)
		player.bossBarCount += 1
	else:
		if bossBar:
			bossBar.hide()

func _process(_delta: float) -> void:
	if bossBar:
		bossBar.value = health
	if health <= 0:
		if not energyGiven:
			player.ammo = 30
			player.targeted = false
			Signals.emit_signal("shakeSmall")
			player.parryEnergy += 10
			energyGiven = true
			player.enemyCount -= 1
			parent.dead = true
			if player.enemyCount == 0:
				player.encounter.y += 1
				Signals.change.emit()
			$"../Explode1".emitting = true
			$"../Explode2".emitting = true
			parent.enemy_sprite.hide()
			await get_tree().create_timer(1).timeout
			player.bossBarCount -= 1
			Signals.emit_signal("bossDeath")
			player.targeted = false
			parent.queue_free()

func parried():
	parent.isParryable = false
	hurt(2)
	Hitstops.shortHitstop()
	player.parry_sfx.play()
	await get_tree().create_timer(0.0011).timeout
	player.parryCooled = true
	player.parryEnergy += 24
	player.ammo = 30
	player.health += 15
	
func hurt(amount):
	emit_signal("hit")
	health -= amount
	#delay stops crashing if hit on frame one
	await get_tree().create_timer(0.0011).timeout
	player.parryEnergy += (amount) * 3
	player.health += (amount) * 3
	parent.enemy_sprite.material.set_shader_parameter("mixAmount",1.0)
	await get_tree().create_timer(0.2).timeout
	parent.enemy_sprite.material.set_shader_parameter("mixAmount",0.0)
	
func _on_destroy():
	player.targeted = false
	await get_tree().create_timer(0.0011).timeout
	player.bossBarCount = 0
	player.enemyCount = 0
	player.targeted = false
	parent.queue_free()
	
func _on_death():
	if isBoss:
		bossBar.show()
		bossBar.position.y -= 15 + 32
