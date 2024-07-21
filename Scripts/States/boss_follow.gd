extends State
class_name BossFollow

@export var boss: CharacterBody2D
@export var move_speed := 60
@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player: CharacterBody2D

func enter():
	player = get_tree().get_first_node_in_group("Player")
	
func physics_update(delta: float):
	var direction = player.global_position - boss.global_position
	
	if direction.length() > 80:
		boss.velocity.x = direction.normalized().x * move_speed
	else:
		transitioned.emit(self, "attack")
	
	if direction.length() > 400:
		transitioned.emit(self, "idle")
		
	boss.velocity.y += gravity * delta
