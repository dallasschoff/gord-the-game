extends State
class_name BossAttack

@export var boss: CharacterBody2D
@export var move_speed := 60
@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player: CharacterBody2D
var can_attack = true

func enter():
	player = get_tree().get_first_node_in_group("Player")
	
func physics_update(delta: float):
	var direction = player.global_position - boss.global_position
	
	if direction.length() > 60:
		transitioned.emit(self, "follow")
	elif direction.length() < 60 and can_attack:
		#continue to attack player if in range
		var lunge_direction = boss.global_position.direction_to(player.global_position)
		var lunge = lunge_direction * move_speed
		boss._attack(lunge)
		
	boss.velocity.y += gravity * delta
