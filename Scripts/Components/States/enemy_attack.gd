extends State
class_name EnemyAttack

@export var enemy: CharacterBody2D
@export var move_speed := 60
@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player: CharacterBody2D
var can_attack = true

func enter():
	enemy.connect("hit_started", _got_hurt)
	player = get_tree().get_first_node_in_group("Player")
	
func physics_update(delta: float):
	var direction = player.global_position - enemy.global_position
	
	if direction.length() > 40:
		transitioned.emit(self, "follow")
	elif direction.length() < 40 and not player._is_dead():
		#continue to attack player if in range
		var lunge_direction = enemy.global_position.direction_to(player.global_position)
		var lunge = lunge_direction * move_speed
		enemy._attack(lunge)
	elif player._is_dead():
		transitioned.emit(self, "goon")
		
	enemy.velocity.y += gravity * delta
	
func _got_hurt():
	transitioned.emit(self, "hurt")
