extends Control
class_name upgrade

var upgrades = {
	1 : "Fragility Curse",
	2 : "Adrenal Fury",
	3 : "Hysterical Strength",
	4: "Speed Link (not done)",
	5 : "Brute Force (not done)",
	6: "Sniper's Curse (not done)",
	7: "7",
	8 : "8",
	9 : "9"
}
@onready var componets: CanvasLayer = $Componets
@onready var upgrade_a: Button = $"Componets/VBoxContainer/HBoxContainer/Upgrade A"
var upgrade1: int = 0
@onready var upgrade_b: Button = $"Componets/VBoxContainer/HBoxContainer/Upgrade B"
var upgrade2: int = 0


func _ready() -> void:
	componets.hide()


func _on_exit_button_up() -> void:
	$".".hide()
	$Componets.hide()
	Engine.time_scale = 1


func _on_upgrade_a_button_up() -> void:
	PlayerData.playerUpgrades.append(upgrade1)
	PlayerData.upgradesLeft.erase(upgrade1)
	$".".hide()
	$Componets.hide()
	Signals.emit_signal("upgrades")
	Engine.time_scale = 1

func _on_upgrade_b_button_up() -> void:
	PlayerData.playerUpgrades.append(upgrade2)
	PlayerData.upgradesLeft.erase(upgrade2)
	$".".hide()
	$Componets.hide()
	Signals.emit_signal("upgrades")
	Engine.time_scale = 1
