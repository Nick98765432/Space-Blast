extends Area2D

var melee: PackedScene = preload("res://Enemies/Scenes/melee enemy.tscn")
var proj: PackedScene = preload("res://Enemies/Scenes/Projectile enemy.tscn")
var fire: PackedScene = preload("res://Enemies/Scenes/FireGuy.tscn")
var dashGuy: PackedScene = preload("res://Enemies/Scenes/DashGuy.tscn")
var teleGuy: PackedScene = preload("res://Enemies/Scenes/teleGuy.tscn")
var bossMan1: PackedScene = preload("res://Enemies/Scenes/BossMan1.tscn")
var aceMan: PackedScene = preload("res://Enemies/Scenes/AceMan.tscn")
var sentryMan: PackedScene = preload("res://Enemies/Scenes/sentryMan.tscn")
var gunMan: PackedScene = preload("res://Enemies/Scenes/GunMan.tscn")
@export var isBoss: bool
@export var type: int
@export var encounter: Vector2i
@export var player: Player


func _ready() -> void:
	Signals.connect("change", _on_change)

func _on_change():
	if encounter == player.encounter:
		match type:
			1:
				spawn(melee)
			2:
				spawn(proj)
			3:
				spawn(fire)
			4:
				spawn(teleGuy)
			5:
				spawn(dashGuy)
			6:
				spawn(bossMan1)
			7:
				spawn(gunMan)
			8:
				spawn(sentryMan)
			9:
				spawn(aceMan)

func spawn(kind: PackedScene):
	var enemy = kind.instantiate()
	enemy.global_position = global_position
	enemy.player = player
	get_tree().get_root().add_child(enemy)
	if isBoss:
		enemy.health_handler.health *= 2
