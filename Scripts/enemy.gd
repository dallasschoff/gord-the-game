extends CharacterBody2D

class_name Enemy

#Enemy trait values
var taking_damage = false
var SPEED = 60 #60 pixels per sec
@onready var TARGET = $"../Player"
@onready var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite = $AnimatedSprite2D

#Animation traits
var hurting_cooldown = 0
var is_idle = abs(velocity.x) < 1 
var is_walking = abs(velocity.x) > 10



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_character(delta)
	_handle_animation_cooldowns()
	var is_idle = abs(velocity.x) < 1 and !is_walking and hurting_cooldown == 0
	var is_walking = abs(velocity.x) > 10 and hurting_cooldown ==0
	if is_walking:
		animated_sprite.play("walking")
	if is_idle:
		animated_sprite.play("idle")


# Handle moving en emy left and right on its own
func move_character(delta):
	if TARGET != null:
		velocity.x = position.direction_to(TARGET.position).x * SPEED
		velocity.y += GRAVITY * delta
		move_and_slide()
		if velocity.x < 0:
			animated_sprite.flip_h = false
		if velocity.x > 0:
			animated_sprite.flip_h = true
		
func knockback(attack: Attack):
	velocity = (global_position - attack.attack_position).normalized() * attack.knockback_force
	move_and_slide()
	print("Knocked back!")

func _on_hurtbox_component_area_entered(area):
	is_walking = false
	is_idle = false
	hurting_cooldown = 36
	animated_sprite.play("hurting")
	#var attack = Attack.new()
	#attack.attack_damage = 10
	#attack.knockback_force = 10
	#attack.attack_position = global_position
	#knockback(Attack)
	print("Enemy hit")

func _handle_animation_cooldowns():
		if hurting_cooldown > 0:
			hurting_cooldown -= 1
