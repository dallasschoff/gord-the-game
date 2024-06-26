extends State
class_name EnemyFollow

@export var enemy: CharacterBody2D
@export var move_speed := 60
@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player: CharacterBody2D

func enter():
	player = get_tree().get_first_node_in_group("Player")
	
func physics_update(delta: float):
	var direction = player.global_position - enemy.global_position
	
	if direction.length() > 25:
		enemy.velocity.x = direction.normalized().x * move_speed
	else:
		#eventually put attack here
		enemy.velocity.x = 0
	
	if direction.length() > 200:
		transitioned.emit(self, "idle")
		
	enemy.velocity.y += gravity * delta
