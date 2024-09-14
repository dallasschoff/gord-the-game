extends State
class_name BossAttack

@export var boss: CharacterBody2D
@export var move_speed := 60
@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player: CharacterBody2D

var can_follow = false

func enter():
	player = get_tree().get_first_node_in_group("Player")
	boss.connect("attack_finished", _attack_animation_finished)
	
func physics_update(delta: float):
	var direction = player.global_position - boss.global_position
	if direction.length() > 60 and can_follow:
		transitioned.emit(self, "follow")
		can_follow = false
	elif direction.length() < 60:
		#continue to attack player if in range
		var lunge_direction = boss.global_position.direction_to(player.global_position)
		var lunge = lunge_direction * move_speed
		can_follow = false
		boss._attack(lunge)
	boss.velocity.y += gravity * delta

func _attack_animation_finished():
	can_follow = true
