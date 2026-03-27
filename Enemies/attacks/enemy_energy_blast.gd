extends Area2D

var speed = 300
var isParriable: bool
var ifParried: bool = false
var type: int
var damage: float = 35
var target: Player
var deflect: bool = false

func _ready() -> void:
	Signals.connect("destroy", _on_destroy)
	if type == 1:
		isParriable = true
		speed = 600
	elif type == 2:
		isParriable = true
	elif type == 3:
		isParriable = true
		speed = 600
		damage = 12
	elif type == 4:
		isParriable = false
		speed = 1000
		damage = 3.5
	
func _physics_process(delta: float) -> void:
	if type == 1 or type == 3 or type == 4:
		global_position += transform.x.normalized() * speed * delta
	if type == 2:
		rotateTo(target)
		global_position += transform.x.normalized() * speed * delta
	
func parried():
	ifParried = true
	speed = 900
	rotation_degrees += 180



func _on_body_entered(body: Node2D) -> void:
	if not(ifParried):
		if isParriable:
			#parriable
			if body is Player:
				if body.parry == false:
					body.damage(damage)
					queue_free()
			if not body.is_in_group("enemies"):
				queue_free()
		else:
			#unparriable
			if body is Player:
				body.damage(damage)
				queue_free()
			elif not body.is_in_group("enemies"):
				queue_free()
	if ifParried:
		if not(body is Player):
			if body.is_in_group("enemies"):
				body.health_handler.hurt(1)
			queue_free()
			
func _on_destroy():
	queue_free()
	
func rotateTo(thing):
	var dir = (thing.global_position - global_position).normalized()
	var angle = transform.x.angle_to(dir)
	rotate(sign(angle) * min(get_process_delta_time() * 2, abs(angle)))


func _on_timer_timeout() -> void:
	queue_free()
