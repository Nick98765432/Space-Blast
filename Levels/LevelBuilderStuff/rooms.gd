extends Node2D
class_name room

@export var roomNum: int = 0

@onready var player = get_tree().get_first_node_in_group("player")
func _ready() -> void:
	for i in get_children():
		for a in i.get_children():
			if a is Spawner:
				a.player = player
				a.encounter.x = roomNum
		
