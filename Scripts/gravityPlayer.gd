extends CharacterBody2D

class_name GravityPlayer

const WALK_FORCE = 600
const WALK_MAX_SPEED = 200
const STOP_FORCE = 1000
const JUMP_SPEED = 300

@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	# Horizontal movement code. First, get the player's input.
	var walk = WALK_FORCE * (Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
	# Flips player sprite based on left and right inputs.
	if Input.get_action_strength("move_left"):
		animated_sprite.flip_h = true
	if Input.get_action_strength("move_right"):
		animated_sprite.flip_h = false
	
	# Play idle animation if not moving
	if velocity.x == 0 and velocity.y ==0:
		animated_sprite.play("idle")
	
	#Play jumping animation if rising/falling
	elif velocity.y != 0:
		animated_sprite.play("jumping")
	

	# Slow down the player if they're not trying to move.
	if abs(walk) < WALK_FORCE * 0.2:
		# The velocity, slowed down a bit, and then reassigned.
		velocity.x = move_toward(velocity.x, 0, STOP_FORCE * delta)
	else:
		velocity.x += walk * delta

	# Clamp to the maximum horizontal movement speed.
	velocity.x = clamp(velocity.x, -WALK_MAX_SPEED, WALK_MAX_SPEED)

	# Vertical movement code. Apply gravity.
	velocity.y += gravity * delta

	# Move based on the velocity and snap to the ground.
	set_velocity(velocity)
	# TODOConverter3To4 looks that snap in Godot 4 is float, not vector like in Godot 3 - previous value `Vector2.DOWN`
	set_up_direction(Vector2.UP)
	move_and_slide()
	velocity = velocity

	# Check for jumping. is_on_floor() must be called after movement code.
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = -JUMP_SPEED

func _on_animated_sprite_2d_animation_finished():
		if is_on_floor():
			animated_sprite.stop()
