extends AudioStreamPlayer
signal music
@onready var player
@export var intro: bool = false

func _ready() -> void:
	await get_tree().create_timer(0.01).timeout
	player = get_tree().get_first_node_in_group("player")
	Signals.lock.emit()
	if intro:
		player.encounter.y  = -1
	
func _on_finished() -> void:
	emit_signal("music")
	if intro:
		player.encounter.y += 1
		await get_tree().create_timer(2).timeout
		Signals.change.emit()
	
