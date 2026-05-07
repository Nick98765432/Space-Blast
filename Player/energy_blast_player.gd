extends Area2D

var player: Node
var speed = 1000
var type = 1
var damageMult: float

func _ready() -> void:
	if type == 2:
		await get_tree().create_timer(0.15).timeout
		queue_free()
func _physics_process(delta: float) -> void:
	global_position += transform.x.normalized() * speed * delta
	



func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		if area.get_parent().dead != true:
			if type == 1:
				area.get_parent().health_handler.hurt(1 * damageMult)
			elif type == 2:
				area.get_parent().health_handler.hurt(0.4375 * damageMult)
			elif type == 3:
				area.get_parent().health_handler.hurt(0.4 * damageMult)
			queue_free()


func _on_body_entered(body: Node2D) -> void:
	if not(body is Player):
		if body is explosiveBarrel:
			body.explode()
		queue_free()
