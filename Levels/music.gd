extends AudioStreamPlayer
@export var intro: AudioStreamPlayer


func _ready() -> void:
	intro.connect("music", _on_music)
	
func _on_music():
	play()
