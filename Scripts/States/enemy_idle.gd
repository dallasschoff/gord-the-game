extends State
class_name EnemyIdle

@export var enemy: Enemy
@export var move_speed := 60
@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var move_direction: float
var wander_time: float
var changed_direction = false
var idle = true

func randomize_wander():
	if idle:
		move_direction = 0
	else:
		move_direction = [-1, 1].pick_random()
	wander_time = randi_range(1, 3)
	
func enter():
	randomize_wander()
	if enemy:
		enemy.connect("blocked", change_direction)
	
func update(delta: float):
	if wander_time > 0:
		wander_time -= delta
	else:
		idle = !idle
		changed_direction = false
		randomize_wander()
		
func physics_update(delta: float):
	if enemy:
		enemy.velocity.x = move_direction * move_speed
		enemy.velocity.y += gravity * delta

func change_direction():
	if !changed_direction:
		print("switching")
		move_direction = -move_direction
		changed_direction = true
		
