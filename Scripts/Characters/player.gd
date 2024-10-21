extends CharacterBody2D
class_name Player

signal died

#Player Attributes
@export var speed := 600
@export var max_speed := 200
@export var jump_strength := 350
@export var double_jump_multiplier := 1.2
@export var stop_force := 1000
@export var double_jumps := 1
#Housekeeping
@export var weapon: Weapon
@export var log_movement := false
@onready var animated_sprite = $AnimatedSprite2D
@onready var animated_sprite_puff = $AnimatedSprite2D/AnimatedSpritePuff
@onready var landing_ray1 = $LandingRay1
@onready var landing_ray2 = $LandingRay2
#Player Conditions
var jumps_made := 0
var double_jumps_made := 0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var terminal_velocity = 700
var attacking_cooldown = 0
var crouching_cooldown = 0
var landing_window = 0
var hurting_cooldown = 0
#Coyote Time
var coyote = false
var last_floor = false
var coyote_timer: Timer
#Running attack properties
var running_attack_boost = false
var running_attack_timer: Timer
#Player knockback
var knockback = Vector2(0,0)
var knockbackTween
var dead = false

var last_ground_position
var ground_level

#@onready var meteor_sprite = $PBMeteor/Meteor
#@onready var explosion_sprite = $PBMeteor/Explosion
#@onready var pb_meteor = $PBMeteor
@export var PBMeteorScene: PackedScene

func _ready():
	#Coyote Time
	coyote_timer = Timer.new()
	add_child(coyote_timer)
	coyote_timer.one_shot = true
	coyote_timer.wait_time = 0.1
	coyote_timer.connect("timeout", _on_coyote_timer_timeout)
	
	#Running attack
	running_attack_timer = Timer.new()
	add_child(running_attack_timer)
	running_attack_timer.one_shot = true
	running_attack_timer.wait_time = 0.2
	running_attack_timer.connect("timeout", _on_running_attack_timer_timeout)
	
	last_ground_position = position.y

func _physics_process(delta):
	if dead:
		return
	#Player States
	var is_in_cooldown := attacking_cooldown > 0 or landing_window > 0 or crouching_cooldown > 0 or hurting_cooldown > 0
	var is_landing = (landing_ray1.is_colliding() or landing_ray2.is_colliding()) and jumps_made >= 1 and velocity.y > 0.0 and !is_on_floor()
	var is_free_falling = velocity.y > 200.0 and !is_on_floor() and jumps_made == 0
	var is_falling = velocity.y > 200.0 and !is_on_floor() and jumps_made == 0 and !is_free_falling
	var is_jumping := attacking_cooldown == 0 and hurting_cooldown == 0 and Input.is_action_just_pressed("jump") and (is_on_floor() or coyote)
	var is_double_jumping := Input.is_action_just_pressed("jump") and velocity.y >= 0 and !is_on_floor() and double_jumps_made != double_jumps
	var is_running = is_on_floor() and !is_zero_approx(velocity.x) and !Input.is_action_pressed("walk") and !is_free_falling and abs(velocity.x) > 50
	var is_walking := is_on_floor() and !is_zero_approx(velocity.x) and Input.is_action_pressed("walk")
	var is_moving = is_walking or is_running
	var is_crouching = is_on_floor() and Input.is_action_pressed("crouch") and !is_moving
	var is_attacking_idle = Input.is_action_pressed("attack") and !is_moving and is_on_floor() and attacking_cooldown == 0
	var is_attacking_running = Input.is_action_pressed("attack") and is_moving and abs(velocity.x) > 100 #and is_on_floor() 
	var is_idling = is_on_floor() and is_zero_approx(velocity.x) and !is_crouching and !is_moving and !is_attacking_idle and !is_in_cooldown 
	
	var move = 0
	var _horizontal_direction
	#Meteor Attack demo
	if Input.is_action_just_pressed("test_button1"):
		print("test 1 meteor")
		var world = get_tree().get_first_node_in_group("World")
		var pb_meteor_instance = PBMeteorScene.instantiate()
		pb_meteor_instance.position = position
		world.add_child(pb_meteor_instance)
		
		var meteor_sprite = pb_meteor_instance.get_child(0)
		var explosion_sprite = pb_meteor_instance.get_child(1)
		#var pb_meteor_root = pb_meteor_attack.get_tree().get_child(-1)
		#pb_meteor_attack.visible = true
		#meteor_sprite.visible = true
		explosion_sprite.visible = false

		world.add_child(pb_meteor_instance)
		meteor_sprite.play("pb meteor")
	
	#Can only move if not hurting or attacking
	if hurting_cooldown == 0 and attacking_cooldown == 0 and crouching_cooldown == 0:
		_horizontal_direction = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")

		if Input.is_action_pressed("walk"):
			speed = 200
			max_speed = 50
		else:
			speed = 600
			max_speed = 200
			
		move = _horizontal_direction * speed

	# Slow down the player if they're not trying to move
	if abs(move) < speed * 0.2:
		# The velocity, slowed down a bit, and then reassigned
		velocity.x = move_toward(velocity.x, 0, stop_force * delta)
	else:
		velocity.x += move * delta
	
	velocity.x = clamp(velocity.x, -max_speed, max_speed)
	velocity.y += gravity * delta
	velocity.y = clamp(velocity.y, -terminal_velocity, terminal_velocity)
	set_up_direction(Vector2.UP)
	_handle_animation_cooldowns()
	
	#All of the "is_" variables used to be here
	
	#Small speed boost / slide to running attack (May want to relocate this)
	if Input.is_action_just_pressed("attack") and is_moving:
		print("running attack boost")
		running_attack_boost = true
		running_attack_timer.start()
	if running_attack_boost:
		if velocity.x > 100: velocity.x = 300
		if velocity.x < -100: velocity.x = -300
	
	#Coyote Time
	if !is_on_floor() and last_floor and jumps_made == 0:
		#print("coyote time")
		coyote = true
		coyote_timer.start()
	last_floor = is_on_floor()
	
	#Apply jump physics
	if is_jumping:
		jumps_made += 1
		velocity.y = -jump_strength
	#Apply double jump physics
	elif is_double_jumping:
		if jumps_made <= double_jumps:
			velocity.y = -jump_strength * double_jump_multiplier
		double_jumps_made += 1
	#Reset jump counters
	elif is_on_floor():
		jumps_made = 0
		double_jumps_made = 0
		
	#Variable Jump Height
	if jumps_made >= 1 and !is_on_floor() and Input.is_action_just_released("jump") and velocity.y < -125:
		velocity.y = -125	
	if is_landing:
		landing_window = 12
	if is_crouching:
		crouching_cooldown = 20
	
	#drop through platforms
	set_collision_mask_value(2, false) if Input.is_action_pressed("crouch") else set_collision_mask_value(2, true)
	
	#Attack hitbox enable / disable
	if animated_sprite.animation == "attack" and (animated_sprite.frame == 3 or animated_sprite.frame == 4):
		weapon.attack_area.set_deferred("disabled", false)
	elif animated_sprite.animation == "running_attack" and animated_sprite.frame >= 2 and animated_sprite.frame <= 5:
		weapon.attack_area.set_deferred("disabled", false)
	else:
		weapon.attack_area.set_deferred("disabled", true)
	
	#Aplly knockback physics
	velocity = velocity + knockback
	_update_ground_position()
	last_ground_position = position.y
	move_and_slide()
	
	#Dallas?
	if hurting_cooldown > 0:
		return
	
	#Handle sprites and hitbox direction changes
	if Input.is_action_pressed("move_left") and attacking_cooldown == 0 and hurting_cooldown == 0:
		animated_sprite.flip_h = true
		weapon.change_direction("left")
		if animated_sprite_puff.position.x < 0:
			animated_sprite_puff.position.x = animated_sprite_puff.position.x + 4.3
	if Input.is_action_pressed("move_right") and attacking_cooldown == 0 and hurting_cooldown == 0:
		animated_sprite.flip_h = false
		animated_sprite_puff.position.x = -2.33
		weapon.change_direction("right")
	
	#Handle sprite puff flip/position when standing still
	if velocity.x == 0 and animated_sprite.flip_h == false:
		animated_sprite_puff.position.x = -2.33
	if velocity.x == 0 and animated_sprite.flip_h == true:
		animated_sprite_puff.position.x = 2
	
	#Player animations
	if is_attacking_running and attacking_cooldown == 0:
		animated_sprite.play("running_attack")
		attacking_cooldown = 36
	elif is_attacking_idle and attacking_cooldown == 0:
		animated_sprite.play("attack")
		attacking_cooldown = 48
	elif is_jumping and !is_landing:
		animated_sprite.play("jumping")
	elif is_double_jumping:
		animated_sprite.play("double_jumping")
		animated_sprite_puff.play("puff")
	elif is_running and !is_jumping and !is_in_cooldown:
		animated_sprite.play("running")
	elif is_landing:
		animated_sprite.play("landing")
	elif is_falling:
		animated_sprite.play("running")
	elif is_free_falling:
		animated_sprite.play("free_falling")
	elif is_walking and !is_jumping:
		animated_sprite.play("walking")
	elif is_crouching:
		animated_sprite.play("crouching")
	elif is_idling:
		animated_sprite.play("idle")
	
	#Movement log
	if log_movement:
		print(animated_sprite.animation)

#--------------------------------#

func _handle_animation_cooldowns():
	if landing_window > 0:
		landing_window -= 1
		
	if attacking_cooldown > 0:
		attacking_cooldown -= 1
		
	if crouching_cooldown > 0:
		crouching_cooldown -= 1
		
	if hurting_cooldown > 0:
		hurting_cooldown -= 1


func _hit(attack: Attack):
	if dead:
		return
	hurting_cooldown = 30
	animated_sprite.play("taking_damage")
	print("Player hit")
	knockback = attack.knockback
	
	knockbackTween = get_tree().create_tween()
	knockbackTween.parallel().tween_property(self, "knockback", Vector2(0,0), 0.5)
	
	animated_sprite.modulate = Color.RED
	knockbackTween.parallel().tween_property(animated_sprite, "modulate", Color.WHITE, 0.5)	

func _die():
	if dead:
		return
	get_node("HurtboxComponent").get_child(0).disabled = true
	animated_sprite.play("death")
	dead = true
	print("Player Died")

func _is_dead():
	return dead

func _on_animation_finished():
	if dead:
		died.emit()

func _on_coyote_timer_timeout():
	coyote = false
	#print("coyote time over")

func _on_running_attack_timer_timeout():
	running_attack_boost = false
	print("running attack boost over")
	
func _update_ground_position():
	var test = position.y
	if last_ground_position == position.y:
		ground_level = position.y

func _get_ground_position():
	print(ground_level)
	return ground_level
