extends Node2D

@onready var particles = $CPUParticles2D
var angle : int
var amount : int
@export var entity: Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	entity.connect("hitspark_signal", _emit_hitspark) #From weapon

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _emit_hitspark():
	angle = randi_range(0, 1)
	amount = randi_range(0, 1)
	particles.restart()
	particles.emitting = true
	#particles.one_shot = true
	#particles.one_shot = false
	if angle == 0:
		particles.rotation_degrees = 157
	if angle == 1:
		particles.rotation_degrees = -157
	#if amount == 0:
		#particles.amount = 60
	#if amount == 1:
		#particles.amount = 120
