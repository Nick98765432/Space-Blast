extends Area2D


var damageDone: bool = false
var playerDamageDone: bool = false

func _ready() -> void:
	Signals.emit_signal("shakeSmall")

func _process(delta: float) -> void:
	if not damageDone:
		for i in get_overlapping_areas():
			if i.is_in_group("enemies"):
				i.get_parent().health_handler.hurt(2.5)
				damageDone = true
				
	#if not playerDamageDone:
		#for i in get_overlapping_bodies():
			#if i is Player:
				#i.damage(30)
				#playerDamageDone = true


func _on_explosion_sprite_animation_finished() -> void:
	queue_free()
