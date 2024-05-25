extends CharacterBody2D

class_name GravityPlayer

var WALK_FORCE = 600
var WALK_MAX_SPEED = 200
const STOP_FORCE = 1000
const JUMP_SPEED = 350

# Action cooldowns
var landing_window = 0
var landing = false
var attacking_cooldown = 0
var attacking = false

var moving = false

@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite = $AnimatedSprite2D
@onready var landing_ray1 = $LandingRay1
@onready var landing_ray2 = $LandingRay2

func _physics_process(delta):
	if Input.is_action_pressed("walk"):
		WALK_FORCE = 200
		WALK_MAX_SPEED = 50
	if Input.is_action_just_released("walk"):
		WALK_FORCE = 600
		WALK_MAX_SPEED = 200

	# Horizontal movement code. First, get the player's input.
	var walk = WALK_FORCE * (Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
	# Flips player sprite based on left and right inputs.

	if Input.get_action_strength("move_left"):
		animated_sprite.flip_h = true

	if Input.get_action_strength("move_right"):
		animated_sprite.flip_h = false

	if landing_window == 0:
		landing = false

	if landing_window > 0:
		landing_window -= 1

	if attacking_cooldown == 0:
		attacking = false

	if attacking_cooldown > 0:
		attacking_cooldown -= 1
		moving = false



	# Play landing animation if landing
	if (landing_ray1.is_colliding() or landing_ray2.is_colliding()) and !is_on_floor() and velocity.y > 0:
		animated_sprite.play("landing")
		landing_window = 16
		landing = true
		print("landing")

	# Play jumping animation if rising/falling
	if velocity.y != 0 and !landing_ray1.is_colliding() and !landing_ray2.is_colliding():
		animated_sprite.play("jumping")
		print("jumping")

	# Play idle animation if not moving
	if velocity.x == 0 and velocity.y == 0 and !landing and !attacking:
		animated_sprite.play("idle")
		moving = false
		print("idle")

	# Play walk  animation if moving on ground at low speed
	if is_on_floor() and abs(velocity.x) > 10 and abs(velocity.x) < 100 and !landing:
		animated_sprite.play("walking")
		moving = true
		print("walking")

	# Play running animation if moving on ground at high speed
	if is_on_floor() and abs(velocity.x) > 100 and !landing:
		animated_sprite.play("running")
		moving = true
		print("running")

	# Play attack animation if attack
	if is_on_floor() and Input.is_action_pressed("attack") and !moving:
		animated_sprite.play("attack")
		attacking_cooldown = 20
		attacking = true
		print("attacking")

	# Play idle animation if landing
	#if is_on_floor():
	#	animated_sprite.play("idle")

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
