extends CharacterBody2D

class_name Player

#Signals
signal healthChanged
signal attackEnemy

#Player Traits
@export var MAX_HEALTH = 100
@onready var CURRENT_HEALTH: int = MAX_HEALTH
var WALK_FORCE = 600
var WALK_MAX_SPEED = 200
const STOP_FORCE = 1000
const JUMP_SPEED = 350
const DOUBLE_JUMP_MULT = 1.2

# Actions/Cooldowns
var landing_window = 0
var landing = false
var attacking_cooldown = 0
var attacking = false
var running_attacking_cooldown = 0
var running_attacking = false
var crouching_cooldown = 0
var crouching = false
var hitting = false
var moving = false
var isHurt: bool = false
var canDoubleJump = true


@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite = $AnimatedSprite2D
@onready var animated_sprite_puff = $AnimatedSprite2D/AnimatedSpritePuff
@onready var landing_ray1 = $LandingRay1
@onready var landing_ray2 = $LandingRay2
@export var enemy: Area2D
@onready var sword_attack = $AttackArea

func _ready():
	healthChanged.emit()

func _physics_process(delta):
	handle_cooldowns()
	handle_player_animations()
	handle_player_movement(delta)

#--------------------------------#

func handle_player_movement(delta):
	if Input.is_action_pressed("walk"):
		WALK_FORCE = 200
		WALK_MAX_SPEED = 50
		moving = true
	if Input.is_action_just_released("walk"):
		WALK_FORCE = 600
		WALK_MAX_SPEED = 200
		moving = true
	
	# Horizontal movement code. First, get the player's input.
	var walk = WALK_FORCE * (Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
	
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
		canDoubleJump = true

	# Check for double jumping.
	if !is_on_floor() and Input.is_action_just_pressed("jump") and canDoubleJump:
		velocity.y = -JUMP_SPEED * DOUBLE_JUMP_MULT
		canDoubleJump = false

#--------------------------------#

func handle_player_animations():
	# Flips player sprite based on left and right inputs.
	if Input.get_action_strength("move_left"):
		animated_sprite.flip_h = true
		if animated_sprite_puff.position.x < 0:
			animated_sprite_puff.position.x = animated_sprite_puff.position.x + 4.3

	if Input.get_action_strength("move_right"):
		animated_sprite.flip_h = false
		animated_sprite_puff.position.x = -2.33

	if velocity.x == 0 and animated_sprite.flip_h == false:
		animated_sprite_puff.position.x = -2.33

	if velocity.x == 0 and animated_sprite.flip_h == true:
		animated_sprite_puff.position.x = 2

	# Play landing animation if landing
	if (landing_ray1.is_colliding() or landing_ray2.is_colliding()) and !is_on_floor() and velocity.y > 0:
		animated_sprite.play("landing")
		landing_window = 12
		landing = true
		running_attacking = false
		print("landing")

# Play jumping animation if rising/falling
	if velocity.y != 0 and !landing_ray1.is_colliding() and !landing_ray2.is_colliding():
		animated_sprite.play("jumping")
		print("jumping")

# Play double jump animation
	if !is_on_floor() and Input.is_action_just_pressed("jump") and !landing_ray1.is_colliding() and !landing_ray2.is_colliding() and canDoubleJump:
		animated_sprite.stop()
		animated_sprite.play("double_jumping")
		animated_sprite_puff.play("puff")
		print("double jumping")

# Reset canDoubleJump state
	if is_on_floor():
		canDoubleJump = true

	# Play idle animation if not moving
	if velocity.x == 0 and velocity.y == 0 and !landing and !attacking and !crouching:
		animated_sprite.play("idle")
		moving = false
		running_attacking = false
		print("idle")

	# Play walk animation if moving on ground at low speed
	if is_on_floor() and abs(velocity.x) > 10 and abs(velocity.x) < 100 and !landing and !running_attacking:
		animated_sprite.play("walking")
		moving = true
		print("walking")

	# Play running animation if moving on ground at high speed
	if is_on_floor() and abs(velocity.x) > 100 and !landing and !running_attacking:
		animated_sprite.play("running")
		moving = true
		print("running")

	# Play attack animation if attack
	if is_on_floor() and Input.is_action_pressed("attack") and !moving and !running_attacking and !attacking:
		animated_sprite.play("attack")
		attacking_cooldown = 24
		attacking = true
		attack_hit()
		print("attacking")

	# Play running_attack animation if moving while attacking
	if is_on_floor() and Input.is_action_pressed("attack") and moving and !running_attacking and !attacking and abs(velocity.x) > 100:
		animated_sprite.play("running_attack")
		attacking_cooldown = 24
		attacking = true
		running_attacking_cooldown = 24
		running_attacking = true
		attack_hit()
		print("running attack")

	# Play crouching animation if crouching
	if is_on_floor() and Input.is_action_pressed("crouch") and !moving and !crouching:
		animated_sprite.play("crouching")
		crouching_cooldown = 20
		crouching = true
		print("crouching")

#--------------------------------#
		
func handle_cooldowns():
	if landing_window == 0:
		landing = false

	if landing_window > 0:
		landing_window -= 1

	if attacking_cooldown == 0:
		attacking = false
		hitting = false

	if attacking_cooldown > 0:
		attacking_cooldown -= 1
		moving = false

	if running_attacking_cooldown == 0:
		running_attacking = false
		hitting = false

	if running_attacking_cooldown > 0:
		running_attacking_cooldown -= 1
		moving = true

	if crouching_cooldown == 0:
		crouching = false

	if crouching_cooldown > 0:
		crouching_cooldown -= 1

#--------------------------------#

func attack_hit():
	if sword_attack.has_overlapping_areas() and !hitting:
		attackEnemy.emit()
		hitting = true
		print("Hit!")
	
#--------------------------------#

func hurt_by_enemy():
	CURRENT_HEALTH -= 5
	healthChanged.emit()
