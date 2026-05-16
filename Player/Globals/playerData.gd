extends Node

var upgradesLeft: Array = [1, 2, 3, 4, 5, 6, 7, 8, 9]
var weapons: Array = [1, 2, 3]
var playerUpgrades: Array = []
var playerSuper: int = 1
var maxHealth: float = 100
var mult: float = 1


func _ready() -> void:
	Signals.connect("upgrades", _on_upgrades)
	
func _on_upgrades():
	if playerUpgrades.has(1):
		maxHealth = 50
		mult = 2
