extends AudioStreamPlayer
@export var intro: AudioStreamPlayer


func _ready() -> void:
	if not intro:
		play()
	else:
		intro.connect("music", _on_music)
func _on_music():
	play()
