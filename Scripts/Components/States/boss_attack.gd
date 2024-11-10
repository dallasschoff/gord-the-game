extends State
class_name BossAttack

@export var boss: CharacterBody2D
@export var move_speed := 60
@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player: CharacterBody2D

var attacking = false

func enter():
	boss.connect("hit_started", _got_hurt)
	player = get_tree().get_first_node_in_group("Player")
	boss.connect("attack_finished", _attack_animation_finished)
	
func physics_update(delta: float):
	var direction = player.global_position - boss.global_position
	if direction.length() > 60 and not attacking:
		transitioned.emit(self, "follow")
	elif direction.length() < 60 and not player._is_dead() and not attacking:
		attacking = true
		#continue to attack player if in range
		var lunge_direction = boss.global_position.direction_to(player.global_position)
		var lunge = lunge_direction * move_speed
		boss._attack(lunge)
	elif player._is_dead():
		transitioned.emit(self, "goon")
	boss.velocity.y += gravity * delta

func _attack_animation_finished():
	attacking = false

func _got_hurt():
	transitioned.emit(self, "hurt")
