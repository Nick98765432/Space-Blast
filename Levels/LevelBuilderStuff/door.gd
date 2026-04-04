extends Node2D

var opened: bool = false
var locked: bool = false
@export var speed: float = 10
@export var red: bool = false
@export var blue: bool = false
@onready var upper: StaticBody2D = $upper
@onready var lower: StaticBody2D = $lower
@onready var player: Player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	Signals.connect("lock", _on_lock)
	Signals.connect("unlock", _on_unlock)


func _process(delta: float) -> void:
	if (not opened) or locked:
		close()
	else:
		open()
	if red:
		if not player.keycards.has("red"):
			locked = true
	if blue:
		if not player.keycards.has("blue"):
			locked = true

func open():
	var delta = get_process_delta_time()
	lower.position.y = lerpf(lower.position.y, 60, speed * delta)
	upper.position.y = lerpf(upper.position.y, -60, speed * delta)

func close():
	var delta = get_process_delta_time()
	lower.position.y = lerpf(lower.position.y, 0, speed * delta)
	upper.position.y = lerpf(upper.position.y, 0, speed * delta)


func _on_open_close_area_body_entered(body: Node2D) -> void:
	if body is Player:
		opened = true


func _on_open_close_area_body_exited(body: Node2D) -> void:
	if body is Player:
		opened = false
		
func _on_lock():
	locked = true

func _on_unlock():
	locked = false
