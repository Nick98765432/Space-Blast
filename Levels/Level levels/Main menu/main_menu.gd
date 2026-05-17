extends Node2D

var level1: PackedScene = preload("res://Levels/Level levels/group 1/Level 1-1.tscn")
var level2: PackedScene = preload("res://Levels/Level levels/group 1/Level 1-2.tscn")
var level3: PackedScene = preload("res://Levels/Level levels/group 1/Level 1-3.tscn")

var level4: PackedScene = preload("res://Levels/Level levels/group 2/Level 2-1.tscn")
var level5: PackedScene = preload("res://Levels/Level levels/group 2/Level 2-2.tscn")
var level6: PackedScene = preload("res://Levels/Level levels/group 2/Level 2-3.tscn")


func _process(delta: float) -> void:
	$Control/TextureRect.rotation_degrees += 20 * delta


func _on_button_button_up() -> void:
	$Control.hide()
	$Control2.show()





func _on_normal_button_up() -> void:
	PlayerData.reset()
	get_tree().change_scene_to_packed(level1)
	



func _on_tester_button_up() -> void:
	$Control2.hide()
	$Control3.show()
	

func _on__button_up() -> void:
	PlayerData.reset()
	PlayerData.weapons = [1, 2, 3]
	get_tree().change_scene_to_packed(level1)
	

func _on_level_12_button_up() -> void:
	PlayerData.reset()
	PlayerData.weapons = [1, 2, 3]
	get_tree().change_scene_to_packed(level2)


func _on_level_13_button_up() -> void:
	PlayerData.reset()
	PlayerData.weapons = [1, 2, 3]
	get_tree().change_scene_to_packed(level3)


func _on_level_21_button_up() -> void:
	PlayerData.reset()
	PlayerData.weapons = [1, 2, 3]
	get_tree().change_scene_to_packed(level4)


func _on_level_22_button_up() -> void:
	PlayerData.reset()
	PlayerData.weapons = [1, 2, 3]
	get_tree().change_scene_to_packed(level5)

func _on_level_23_button_up() -> void:
	PlayerData.reset()
	PlayerData.weapons = [1, 2, 3]
	get_tree().change_scene_to_packed(level6)


func _on_credit_button_up() -> void:
	$Control.hide()
	$Control4.show()

func _on_back_button_up() -> void:
	$Control4.hide()
	$Control.show()
	
