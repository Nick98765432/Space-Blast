extends Node2D
class_name healthHandler
signal hit

var player
var energyGiven = false
@onready var parent: Node = $".."
@export var health: float

func _ready() -> void:
	await get_tree().create_timer(0.001).timeout
	player = parent.player
	player.enemyCount += 1
	Signals.connect("destroy", _on_destroy)

func _process(_delta: float) -> void:
	if health <= 0:
		if not energyGiven:
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
			parent.queue_free()

func parried():
	parent.isParryable = false
	player.parryCooled = true
	player.parryEnergy += 24
	player.ammo = 30
	player.health += 15
	hurt(2)
	Hitstops.shortHitstop()
	
func hurt(amount):
	emit_signal("hit")
	player.parryEnergy += (amount) * 3
	player.health += (amount) * 3
	health -= amount
	parent.enemy_sprite.material.set_shader_parameter("mixAmount",1.0)
	await get_tree().create_timer(0.2).timeout
	parent.enemy_sprite.material.set_shader_parameter("mixAmount",0.0)
	
func _on_destroy():
	player.enemyCount = 0
	parent.queue_free()
	
