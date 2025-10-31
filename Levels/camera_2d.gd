extends Camera2D
@export var player: Player
var dir: Vector2 = Vector2.ZERO
var strength: float = 0
var currentRoom: Vector2
var realscreenSize: Vector2
const screenSize: Vector2 = Vector2(640, 360)


func _ready() -> void:
	Signals.connect("shakeSmall", _on_shake_small)
	currentRoom = (player.global_position / realscreenSize).floor()
	
func _process(delta: float) -> void:
	realscreenSize = screenSize / zoom
	currentRoom = (player.global_position / realscreenSize).floor()
	update()
	dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	offset = (dir * strength)
	strength = lerpf(strength, 0, 5 * delta)
	
func _on_shake_small():
	strength = 2
	
func update():
	global_position =  (currentRoom * realscreenSize) + Vector2(realscreenSize.x / 2, realscreenSize.y / 2)
	player.spawnLocation =  (currentRoom * realscreenSize) + Vector2(realscreenSize.x / 2, realscreenSize.y / 2)
