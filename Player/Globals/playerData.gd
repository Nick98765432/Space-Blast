extends Node

var upgradesLeft: Array = [1, 2, 3, 4, 5, 6, 7, 8, 9]
var weapons: Array = [1]
var playerUpgrades: Array = []
var deaths: int = 0
var playerSuper: int = 1
var level: int
var maxHealth: float = 100
var mult: float = 1
var time: float = 0
var nextLevel: PackedScene


func _ready() -> void:
	Signals.connect("upgrades", _on_upgrades)
	
func _on_upgrades():
	if playerUpgrades.has(1):
		maxHealth = 50
		mult = 2

func _process(delta: float) -> void:
	time += delta
	roundNearestHundredth()
func roundNearestHundredth():
	time *= 100
	time = round(time)
	time /= 100

func reset():
	deaths = 0
	time = 0
