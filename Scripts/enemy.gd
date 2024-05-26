extends CharacterBody2D

class_name Enemy

#Enemy trait values
var taking_damage = false
var SPEED = 30 #30 pixels per sec
@onready var TARGET = $"../Player"
@onready var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_character(delta)
	
# Handle moving character left and right on its own
func move_character(delta):
	if TARGET != null:
		velocity.x = position.direction_to(TARGET.position).x * SPEED
		velocity.y += GRAVITY * delta
		move_and_slide()
		
func knockback(attack: Attack):
	velocity = (global_position - attack.attack_position).normalized() * attack.knockback_force
	move_and_slide()
	print("Knocked back!")
