extends Node2D
class_name Particles

var parent
@onready var parry_tele: GPUParticles2D = $parryTele
@onready var unparry_tele: GPUParticles2D = $unparryTele
@onready var spawn_part: GPUParticles2D = $spawnPart
@onready var teleport: GPUParticles2D = $Teleport
@onready var death: GPUParticles2D = $Explode1
@onready var explode_2: GPUParticles2D = $Explode2

func _ready() -> void:
	parent = get_parent()
	teleport.set_as_top_level(true)
	spawn_part.emitting = true

func _physics_process(delta: float) -> void:
	parry_tele.rotation = parent.enemy_sprite.rotation
	unparry_tele.rotation = parent.enemy_sprite.rotation
