extends State
class_name EnemyFollow

@export var enemy: CharacterBody2D
@export var move_speed := 60
@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player: CharacterBody2D

func enter():
	enemy.connect("hit_started", _got_hurt)
	player = get_tree().get_first_node_in_group("Player")
	player.connect("died", _start_gooning)
#	Trying to get the enemy not to chase the player off a cliff
	#if enemy:
		#enemy.connect("blocked", stop) 
	
func physics_update(delta: float):
	var direction = player.global_position - enemy.global_position
	
	if direction.length() > 40:
		enemy.velocity.x = direction.normalized().x * move_speed
	else:
		transitioned.emit(self, "attack")
	
	if direction.length() > 300:
		transitioned.emit(self, "idle")
		
	enemy.velocity.y += gravity * delta

func stop():
	enemy.velocity.x = enemy.velocity.x * 0

	
func _got_hurt():
	transitioned.emit(self, "hurt")
	
func _start_gooning():
	var distance = player.global_position - enemy.global_position
	if (distance.length() < 250):
		transitioned.emit(self, "goon")
