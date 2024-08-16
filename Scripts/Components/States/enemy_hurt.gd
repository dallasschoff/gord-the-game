extends State
class_name EnemyHurt

@export var enemy: Enemy
@export var move_speed := 60
@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player: CharacterBody2D
	
func enter():
	player = get_tree().get_first_node_in_group("Player")
	enemy.connect("hit_finished", _hit_finished)
	
func physics_update(delta: float):
	if enemy:
		enemy.velocity.x = 0
		enemy.velocity.y += gravity * delta
	
func _hit_finished():
	transitioned.emit(self, "idle")