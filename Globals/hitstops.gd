extends Node

signal stopped
signal finished
var isStopped = false

func shortHitstop():
	stop()
	isStopped = true
	Engine.time_scale = 0
	await get_tree().create_timer(0.1, true, false, true).timeout
	isStopped = false
	Engine.time_scale = 1
	emit_signal("finished")

func stop():
	emit_signal("stopped")
