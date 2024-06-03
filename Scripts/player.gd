extends CharacterBody2D
class_name Player

@export var speed := 600
@export var max_speed := 200
@export var jump_strength := 350
@export var double_jump_multiplier := 1.2
@export var stop_force := 1000
@export var maxium_jumps := 2
@export var weapon: Weapon
@onready var animated_sprite = $AnimatedSprite2D
@onready var animated_sprite_puff = $AnimatedSprite2D/AnimatedSpritePuff
@onready var landing_ray1 = $LandingRay1
@onready var landing_ray2 = $LandingRay2
var jumps_made := 0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var attacking_cooldown = 0
var crouching_cooldown = 0
var landing_window = 0

func _physics_process(delta):
	var _horizontal_direction = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
	if Input.is_action_pressed("walk"):
		speed = 200
		max_speed = 50
	else:
		speed = 600
		max_speed = 200
		
	var walk = _horizontal_direction * speed
	
	# Slow down the player if they're not trying to move
	if abs(walk) < speed * 0.2:
		# The velocity, slowed down a bit, and then reassigned
		velocity.x = move_toward(velocity.x, 0, stop_force * delta)
	else:
		velocity.x += walk * delta
	
	velocity.x = clamp(velocity.x, -max_speed, max_speed)
	velocity.y += gravity * delta
	set_up_direction(Vector2.UP)
	_handle_animation_cooldowns()
	
	var is_in_cooldown := attacking_cooldown > 0 or landing_window > 0 or crouching_cooldown > 0
	var is_landing = (landing_ray1.is_colliding() or landing_ray2.is_colliding()) and jumps_made >= 1 and velocity.y > 0.0 and !is_on_floor()
	var is_free_falling = velocity.y > 200.0 and !is_on_floor() and jumps_made == 0
	var is_falling = velocity.y > 0.0 and !is_on_floor() and jumps_made == 0 and !is_free_falling
	var is_jumping := Input.is_action_just_pressed("jump") and is_on_floor()
	var is_double_jumping := Input.is_action_just_pressed("jump") and velocity.y >= 0 and !is_on_floor()
	var is_running = is_on_floor() and !is_zero_approx(velocity.x) and !Input.is_action_pressed("walk") and !is_free_falling
	var is_walking := is_on_floor() and !is_zero_approx(velocity.x) and Input.is_action_pressed("walk")
	var is_moving = is_walking or is_running
	var is_crouching = is_on_floor() and Input.is_action_pressed("crouch") and !is_moving
	var is_attacking_idle = Input.is_action_pressed("attack") and !is_moving and is_on_floor()
	var is_attacking_running = Input.is_action_pressed("attack") and is_moving and is_on_floor() and abs(velocity.x) > 100
	var is_idling = is_on_floor() and is_zero_approx(velocity.x) and !is_crouching and !is_moving and !is_attacking_idle and !is_in_cooldown
	
	var jump_limit_reached = false
	if is_jumping:
		jumps_made += 1
		velocity.y = -jump_strength
	elif is_double_jumping:
		jumps_made += 1
		if jumps_made <= maxium_jumps:
			velocity.y = -jump_strength * double_jump_multiplier
		else:
			jump_limit_reached = true
	elif is_on_floor():
		jumps_made = 0
	
	if is_landing:
		landing_window = 12
	if is_crouching:
		crouching_cooldown = 20
	
	move_and_slide()
	
	if Input.is_action_pressed("move_left"):
		animated_sprite.flip_h = true
		weapon.change_direction("left")
		if animated_sprite_puff.position.x < 0:
			animated_sprite_puff.position.x = animated_sprite_puff.position.x + 4.3
	if Input.is_action_pressed("move_right"):
		animated_sprite.flip_h = false
		animated_sprite_puff.position.x = -2.33
		weapon.change_direction("right")
	
	if velocity.x == 0 and animated_sprite.flip_h == false:
		animated_sprite_puff.position.x = -2.33

	if velocity.x == 0 and animated_sprite.flip_h == true:
		animated_sprite_puff.position.x = 2
	
	if is_attacking_running:
		print("attacking moving")
		animated_sprite.play("running_attack")
		attacking_cooldown = 24
		weapon.attack_area.set_deferred("disabled", false)
	elif is_attacking_idle:
		print("attacking idle")
		animated_sprite.play("attack")
		attacking_cooldown = 24
		weapon.attack_area.set_deferred("disabled", false)
	elif is_jumping and !is_landing:
		print("jumping")
		animated_sprite.play("jumping")
	elif is_double_jumping and !jump_limit_reached:
		print("double jumping")
		animated_sprite.play("double_jumping")
		animated_sprite_puff.play("puff")
	elif is_running and !is_jumping and !is_in_cooldown:
		print("running")
		animated_sprite.play("running")
	elif is_landing:
		print("landing")
		animated_sprite.play("landing")
	elif is_falling:
		print("falling")
		animated_sprite.play("running")
	elif is_free_falling:
		print("free falling")
		animated_sprite.play("free_falling")
	elif is_walking and !is_jumping:
		print("walking")
		animated_sprite.play("walking")
	elif is_crouching:
		print("crouching")
		animated_sprite.play("crouching")
	elif is_idling:
		print("idle")
		animated_sprite.play("idle")

#--------------------------------#

func _handle_animation_cooldowns():
	if landing_window > 0:
		landing_window -= 1
		
	if attacking_cooldown > 0:
		attacking_cooldown -= 1
		
	if crouching_cooldown > 0:
		crouching_cooldown -= 1
		
	if attacking_cooldown == 0:
		weapon.attack_area.set_deferred("disabled", true)
