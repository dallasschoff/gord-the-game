extends State
class_name BossGoon

@export var boss: Boss
@export var move_speed := 60
@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player: CharacterBody2D
	
func enter():
	boss._goon()
	
func physics_update(delta: float):
	if boss:
		boss.velocity.x = 0
		boss.velocity.y += gravity * delta