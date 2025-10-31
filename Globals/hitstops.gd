extends Node

func shortHitstop():
	Engine.time_scale = 0
	await get_tree().create_timer(0.1, true, false, true).timeout
	Engine.time_scale = 1
