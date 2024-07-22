extends State
class_name BossIdle

@export var boss: Boss
@export var move_speed := 60
@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player: CharacterBody2D
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
	player = get_tree().get_first_node_in_group("Player")
	randomize_wander()
	if boss:
		boss.connect("blocked", change_direction)
	
func update(delta: float):
	if wander_time > 0:
		wander_time -= delta
	else:
		idle = !idle
		changed_direction = false
		randomize_wander()
		
func physics_update(delta: float):
	if boss:
		boss.velocity.x = move_direction * move_speed
		boss.velocity.y += gravity * delta
	
	var direction = player.global_position - boss.global_position
	if direction.length() < 200:
		transitioned.emit(self, "follow")
		
func change_direction():
	if !changed_direction:
		move_direction = -move_direction
		changed_direction = true
		
