extends StaticBody2D


var up1
var up2
var isActive: bool = true
@export var player: Player
@export var ui: upgrade
@onready var area_2d: Area2D = $Area2D

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	if global_position.y < player.global_position.y:
		z_index = 0
	else:
		z_index = 2
	if area_2d.get_overlapping_bodies().has(player) and Input.is_action_just_pressed("interact") and isActive:
		up1 = PlayerData.upgradesLeft.pick_random()
		up2 = PlayerData.upgradesLeft.pick_random()
		while up2 == up1:
			up2 = PlayerData.upgradesLeft.pick_random()
		ui.componets.show()
		ui.show()
		ui.upgrade1 = up1
		ui.upgrade2 = up2
		ui.upgrade_a.text = ui.upgrades[up1]
		ui.upgrade_b.text = ui.upgrades[up2]
		Engine.time_scale = 0
		isActive = false
