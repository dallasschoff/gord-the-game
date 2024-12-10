extends CharacterBody2D

class_name Boss

signal blocked
signal attack_finished
signal hit_started
signal hit_finished

#Enemy trait values
var SPEED = 60
@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite = $BossSprite
@export var next_stagger_time: float = 10.0
@export var raycasts: Node2D
@export var wall_raycast: RayCast2D
@export var floor_raycast: RayCast2D
@export var weapon: Weapon
@export var HeartPickup: PackedScene
@export var Meteor: PackedScene
@export var Wall: PackedScene

#Animation traits
var hurting_cooldown = 0
var attack_cooldown = 0
var meteor_cooldown = 0
var wall_cooldown = 0
var is_idle
var is_walking
var right_colliding = false
var left_colliding = false
var knockback = Vector2(0,0)
var tween
var lunge = Vector2(0,0)
var getting_hit = false
var stagger_timer: Timer
var will_stagger = true
var gooning = false
var dead = false

var wall_offset

func _ready():
	#Initialize next-stagger timer
	stagger_timer = Timer.new()
	add_child(stagger_timer)
	stagger_timer.one_shot = true
	stagger_timer.wait_time = next_stagger_time
	stagger_timer.connect("timeout", _reset_stagger)

#This will run when the stagger_timer times out
func _reset_stagger():
	will_stagger = true
	#Color flash, then "white" back to normal
	animated_sprite.modulate = Color.AQUA
	await get_tree().create_timer(0.1).timeout
	animated_sprite.modulate = Color.WHITE

func _physics_process(delta):
	if dead:
		return
	
	if gooning:
		animated_sprite.play("goon")
		return
	
	if meteor_cooldown > 0:
		#Decrement meteor_cooldown
		meteor_cooldown -= 1
		return
	if wall_cooldown > 0:
		#Decrement wall_cooldown
		wall_cooldown -= 1
		return
	if attack_cooldown > 0 and not getting_hit and not gooning:
		#Attack Hitbox
		if animated_sprite.animation == "attack" and (animated_sprite.frame >= 3 and animated_sprite.frame <= 5):
			weapon.attack_area.set_deferred("disabled", false)
		else:
			weapon.attack_area.set_deferred("disabled", true)
		#Decrement attack_cooldown
		attack_cooldown -= 1
		#Emit attack_finished once the attack_cooldown has reached 0
		if attack_cooldown == 0:
			attack_finished.emit()
		return
	#This turns off the attack hitbox if the attack is ever interrupted
	if animated_sprite.animation == "attack":
		pass
	else:
		weapon.attack_area.set_deferred("disabled", true)
	move_and_slide()
	
	if hurting_cooldown > 0:
		#animated_sprite.play("hurting")
		hurting_cooldown -= 1
		if hurting_cooldown == 0:
			getting_hit = false
			hit_finished.emit() #This goes to boss_hurt.gd
			attack_finished.emit()
		return
	
	if abs(velocity.x) > 0 and abs(velocity.x) <= (boss_idle.move_speed):
		animated_sprite.play("walking")
	elif abs(velocity.x) > (boss_idle.move_speed):
		animated_sprite.play("running")
	else:
		animated_sprite.play("idle")
		
	if velocity.x < 0:
		_look_left()
	if velocity.x > 0:
		_look_right()
		
	if wall_raycast.is_colliding() or (is_on_floor() and !floor_raycast.is_colliding()):
		blocked.emit()

func _hit(attack: Attack):
	is_walking = false
	is_idle = false
	getting_hit = true
	weapon.attack_area.set_deferred("disabled", true)
	attack_cooldown = 0

	#If the Boss will stagger this hit, set the hurting_cooldown to a higher value
	#and play the stagger animation. Also start the stagger_timer to emulate a
	#period when the Boss will not stagger for.
	if will_stagger:
		#Amount of time staggered (frames)
		hurting_cooldown = 160
		animated_sprite.play("stagger")
		stagger_timer.start()
	
	#Else, the Boss will not stagger, so use normal hurting_cooldown value
	#and play the hurting animation
	#else:
		#hurting_cooldown = 36
		#animated_sprite.play("hurting")
	#Color red flash, then Orange while staggered
	animated_sprite.modulate = Color.RED
	await get_tree().create_timer(0.12).timeout
	animated_sprite.modulate = Color(1, 0.67, 0.25, 1)
	print("Boss hit")
	#Set will_stagger to false, regardless, as it will only be true when stagger_timer
	#has hit timeout
	will_stagger = false
	hit_started.emit()
	
func _look_left():
	weapon.change_direction("left")
	animated_sprite.flip_h = false
	raycasts.scale.x = 1

func _look_right():
	weapon.change_direction("right")
	animated_sprite.flip_h = true
	raycasts.scale.x = -1

func _die():
	if dead:
		return
	dead = true
	animated_sprite.play("death")
	var heart = HeartPickup.instantiate()
	heart.healValue = 50.0
	heart.heartScale = Vector2(2,2)
	heart.scaleTime = 1.5
	heart.position = Vector2(position.x, position.y-8)
	get_node("..").add_child(heart)
	
	
func _attack():
	if not getting_hit and not gooning:
		animated_sprite.play("attack")
		attack_cooldown = 48

func _cast_meteor(player_velocity, player_position, ground_level):
	if attack_cooldown <= 0 and meteor_cooldown <= 0:
		animated_sprite.play("cast meteor")
		#instantiate meteor
		var meteor = Meteor.instantiate()
		var meteor_x = player_velocity.x + player_position.x
		meteor_x = clamp(meteor_x, $"..".boss_room_left, $"..".boss_room_right)
		#Raycast for y
		var space_state = get_world_2d().direct_space_state
		# use global coordinates, not local to node
		var query = PhysicsRayQueryParameters2D.create(
			Vector2(meteor_x, player_position.y), Vector2(meteor_x, player_position.y + 300), 1
			)
		var result = space_state.intersect_ray(query)
		var meteor_y = result.position.y
		
		print("result.position.y ", result.position.y)
		meteor.position = Vector2(meteor_x, meteor_y)
		meteor.scale.x = 1 if animated_sprite.flip_h == false else -1
		get_node("..").add_child(meteor)
		print("cast meteor")
		meteor_cooldown = 36

func _cast_wall(player_velocity, player_position, ground_level):
	if attack_cooldown <= 0 and wall_cooldown <= 0:
		animated_sprite.play("cast wall") #Replace with "cast wall" later
		#instantiate wall
		var wall = Wall.instantiate()
		#determine player position relative to boss
		if $".".position.x - player_position.x > 0: #Player is left of boss
			wall_offset = -100
		else: #Player is right of boss
			wall_offset = 100
		var wall_x = player_position.x + wall_offset
		wall_x = clamp(wall_x, $"..".boss_room_left, $"..".boss_room_right)
		#Raycast for y
		var space_state = get_world_2d().direct_space_state
	# use global coordinates, not local to node
		var query = PhysicsRayQueryParameters2D.create(
			Vector2(wall_x, player_position.y), Vector2(wall_x, player_position.y + 300), 1
			)
		var result = space_state.intersect_ray(query)
		var wall_y = result.position.y
		wall.position = Vector2(wall_x, wall_y)
		wall.scale.x = 1 if animated_sprite.flip_h == false else -1
		get_node("..").add_child(wall)
		print("cast wall")
		wall_cooldown = 108

func _goon():
	gooning = true

func _on_boss_sprite_animation_finished():
	if dead:
		queue_free()
