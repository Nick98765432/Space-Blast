extends Control
class_name endScreen


var time: float
var level: int
var rank: int
var deaths: int
var nextLevel: PackedScene
@onready var lettter_label: Label = $VBoxContainer/LettterLabel
@onready var time_label: Label = $VBoxContainer/TimeLabel
@onready var death_label: Label = $VBoxContainer/DeathLabel

var letterRank = {
	5: "S",
	4: "A",
	3: "B",
	2: "C",
	1: "D"
}

func _ready() -> void:
	time = PlayerData.time
	level = PlayerData.level
	deaths = PlayerData.deaths
	nextLevel = PlayerData.nextLevel
	if level == 6:
		nextLevel = load("res://Levels/Level levels/Main menu/Main Menu.tscn")
	findRank()


func findRank():
	if level == 1:
		if time <= 110:
			rank = 5
		elif time <= 125:
			rank = 4
		elif time <= 135:
			rank = 3
		elif time <= 145:
			rank = 2
		else:
			rank = 1
	elif level == 2:
		if time <= 115:
			rank = 5
		elif time <= 130:
			rank = 4
		elif time <= 140:
			rank = 3
		elif time <= 150:
			rank = 2
		else:
			rank = 1
	elif level == 3:
		if time <= 180:
			rank = 5
		elif time <= 195:
			rank = 4
		elif time <= 205:
			rank = 3
		elif time <= 215:
			rank = 2
		else:
			rank = 1
	elif level == 4:
		if time <= 95:
			rank = 5
		elif time <= 110:
			rank = 4
		elif time <= 120:
			rank = 3
		elif time <= 130:
			rank = 2
		else:
			rank = 1
	elif level == 5:
		if time <= 200:
			rank = 5
		elif time <= 215:
			rank = 4
		elif time <= 225:
			rank = 3
		elif time <= 235:
			rank = 2
		else:
			rank = 1
	elif level == 6:
		if time <= 80:
			rank = 5
		elif time <= 95:
			rank = 4
		elif time <= 105:
			rank = 3
		elif time <= 115:
			rank = 2
		else:
			rank = 1
	rank -= deaths
	if rank <= 0:
		rank = 1
	lettter_label.text = letterRank[rank]
	time_label.text = str(time)
	death_label.text = "Deaths: " + str(deaths)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		PlayerData.reset()
		get_tree().change_scene_to_packed(nextLevel)
