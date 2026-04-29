extends Node2D
class_name rocket

var speed = 1200
var isParriable: bool = false
var ifParried: bool = false
var damage: float = 40
var target: Player
var deflect: bool = false
var explosion: PackedScene = preload("res://Enemies/attacks/Explosion.tscn")
@onready var hitbox: Area2D = $hitbox


func _ready() -> void:
	Signals.connect("destroy", _on_destroy)

	
func _physics_process(delta: float) -> void:
	global_position += transform.x.normalized() * speed * delta

func parried():
	ifParried = true
	hitbox.ifParried = true
	speed = 900
	rotation_degrees += 180

func explode():
	var boom = explosion.instantiate()
	boom.global_position = global_position
	get_tree().get_root().add_child(boom)
	queue_free()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if not(ifParried):
		if isParriable:
			#parriable
			if body is Player:
				if body.parry == false:
					if not body.isDashing:
						explode()
			if not body.is_in_group("enemies"):
				explode()
		else:
			#unparriable
			if body is Player:
				if not body.isDashing:
					explode()
			elif not body.is_in_group("enemies"):
				explode()
	if ifParried:
		if not(body is Player):
			if body.is_in_group("enemies"):
				body.health_handler.hurt(1)
			queue_free()
			#change this to explode later
			

func _on_destroy():
	queue_free()
	
func rotateTo(thing):
	var dir = (thing.global_position - global_position).normalized()
	var angle = transform.x.angle_to(dir)
	rotate(sign(angle) * min(get_process_delta_time() * 2, abs(angle)))


func _on_timer_timeout() -> void:
	queue_free()
