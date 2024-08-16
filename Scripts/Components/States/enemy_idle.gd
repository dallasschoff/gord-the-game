extends State
class_name EnemyIdle

@export var enemy: Enemy
@export var move_speed := 60
@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player: CharacterBody2D
var move_direction: float
var looking_direction: float = -1
var wander_time: float
var changed_direction = false
var idle = true

func randomize_wander():
	if idle:
		move_direction = 0
		wander_time = randi_range(3, 5)
	else:
		move_direction = [-1, 1].pick_random()
		looking_direction = move_direction
		wander_time = randi_range(2, 4)
	
func enter():
	player = get_tree().get_first_node_in_group("Player")
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
	
	var direction = 1 if player.global_position.x > enemy.global_position.x else -1
	var distance = player.global_position - enemy.global_position
	if (distance.length() < 200 and direction == looking_direction) or (distance.length() < 50 and direction != looking_direction):
		transitioned.emit(self, "follow")
		
func change_direction():
	if !changed_direction:
		move_direction = -move_direction
		looking_direction = move_direction
		changed_direction = true
