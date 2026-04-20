extends Node2D
class_name phaseDash

var parent := get_parent()
var sounds: Sounds
var particles: Particles
var player: Player
var trailState: int = -1
var dashDir: Vector2 = Vector2.ZERO
var isDashing: bool = false
@onready var dash_trail: Line2D = $dashTrail
@export var stamina: int = 3
@export var maxStamina: int = 3
@export var dashDur: float = 0.3
@export var dashSpeed: float = 35000

func _ready() -> void:
	await get_tree().create_timer(0.01).timeout
	parent = get_parent()
	sounds = parent.sounds
	particles = parent.particles
	player = parent.player


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if isDashing:
		parent.velocity = dashSpeed * dashDir * delta
		dash_trail.points[1] = parent.global_position
	match trailState:
		0:
			dash_trail.width = lerpf(dash_trail.width, 15, 15 * delta)
		1:
			dash_trail.width = lerpf(dash_trail.width, 0.1, 15 * delta)
			if dash_trail.width < 3:
				dash_trail.hide()
				trailState = -1

func dash(direction: Vector2):
	particles.dash_part.global_position = parent.global_position
	if stamina > 0 and not isDashing:
		var dir = -1
		dashDir = direction
		isDashing = true
		stamina -= 1
		parent.enemy_sprite.hide()
		particles.dash_part.restart()
		dash_trail.points[0] = parent.global_position
		dash_trail.points[1] = parent.global_position
		dash_trail.show()
		trailState = 0
		await get_tree().create_timer(dashDur).timeout
		trailState = 1
		parent.enemy_sprite.show()
		isDashing = false
