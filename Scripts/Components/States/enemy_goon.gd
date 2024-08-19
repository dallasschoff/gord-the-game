extends State
class_name EnemyGoon

@export var enemy: Enemy
@export var move_speed := 60
@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player: CharacterBody2D
	
func enter():
	enemy._goon()
	
func physics_update(delta: float):
	if enemy:
		enemy.velocity.x = 0
		enemy.velocity.y += gravity * delta
