extends Area2D
class_name Spawner

@export var guy: PackedScene
@export var extraHealth: bool
@export var bar: bool
@export var drop: bool
@export var encounter: Vector2i
@export var player: Player
@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
	Signals.connect("change", _on_change)
	sprite_2d.hide()
	monitorable = false
	monitoring = false
	
func _on_change():
	if encounter == player.encounter:
		spawn(guy)

func spawn(kind: PackedScene):
	var enemy = kind.instantiate()
	enemy.global_position = global_position
	enemy.player = player
	get_tree().get_root().add_child(enemy)
	if extraHealth:
		enemy.health_handler.health *= 2
	if bar:
		enemy.health_handler.isBoss = true
	if drop: 
		enemy.drop = true
