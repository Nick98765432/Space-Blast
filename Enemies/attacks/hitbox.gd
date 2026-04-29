extends Area2D


var isParriable: bool
var ifParried: bool = false
func _ready() -> void:
	isParriable = get_parent().isParriable
