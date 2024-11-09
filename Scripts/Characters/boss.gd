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
@export var raycasts: Node2D
@export var wall_raycast: RayCast2D
@export var floor_raycast: RayCast2D
@export var weapon: Weapon
@export var HeartPickup: PackedScene
@export var Meteor: PackedScene
#Animation traits
var hurting_cooldown = 0
var attack_cooldown = 0
var meteor_cooldown = 0
var is_idle
var is_walking
var right_colliding = false
var left_colliding = false
var knockback = Vector2(0,0)
var tween
var lunge = Vector2(0,0)
var attack_just_finished = false
var getting_hit = false
var stagger_timer: Timer
var will_stagger = true

func _ready():
	#Initialize stagger timer
	stagger_timer = Timer.new()
	add_child(stagger_timer)
	stagger_timer.one_shot = true
	stagger_timer.wait_time = 10.0
	stagger_timer.connect("timeout", _reset_stagger)

#This will run when the stagger_timer times out
func _reset_stagger():
	will_stagger = true
	animated_sprite.modulate = Color.AQUA
	await get_tree().create_timer(0.1).timeout
	animated_sprite.modulate = Color.WHITE

func _physics_process(delta):
	if meteor_cooldown > 0:
		#Decrement meteor_cooldown
		animated_sprite.play("cast meteor")
		meteor_cooldown -= 1
		return
	if attack_cooldown > 0 and not getting_hit:
		#Decrement attack_cooldown
		attack_cooldown -= 1
		if attack_cooldown == 0:
			attack_just_finished = true
		#Attack Hitbox
		if animated_sprite.animation == "attack" and (animated_sprite.frame >= 3 and animated_sprite.frame <= 5):
			weapon.attack_area.set_deferred("disabled", false)
		else:
			weapon.attack_area.set_deferred("disabled", true)
		return
	#Attack_finished signal to boss_attack.gd
	elif attack_cooldown <= 0 and attack_just_finished:
		attack_finished.emit()
		attack_just_finished = false
		
	move_and_slide()
	
	if hurting_cooldown > 0:
		#animated_sprite.play("hurting")
		hurting_cooldown -= 1
		return
	else:
		getting_hit = false
		hit_finished.emit()
	
	if abs(velocity.x) > 0 and abs(velocity.x) <= (boss_idle.move_speed):
		animated_sprite.play("walking")
	elif abs(velocity.x) > (boss_idle.move_speed):
		animated_sprite.play("running")
	else:
		animated_sprite.play("idle")
		
	if velocity.x < 0:
			weapon.change_direction("left")
			animated_sprite.flip_h = false
			raycasts.scale.x = 1
	if velocity.x > 0:
		weapon.change_direction("right")
		animated_sprite.flip_h = true
		raycasts.scale.x = -1
		
	if wall_raycast.is_colliding() or (is_on_floor() and !floor_raycast.is_colliding()):
		blocked.emit()

func _hit(attack: Attack):
	is_walking = false
	is_idle = false
	getting_hit = true
	animated_sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	animated_sprite.modulate = Color(1, 0.67, 0.25, 1)

	#If the Boss will stagger this hit, set the hurting_cooldown to a higher value
	#and play the stagger animation. Also start the stagger_timer to emulate a
	#period when the Boss will not stagger for.
	if will_stagger:
		hurting_cooldown = 210
		animated_sprite.play("stagger")
		stagger_timer.start()
	#Else, the Boss will not stagger, so use normal hurting_cooldown value
	#and play the hurting animation
	#else:
		#hurting_cooldown = 36
		#animated_sprite.play("hurting")
	print("Boss hit")
	#Set will_stagger to false, regardless, as it will only be true when stagger_timer
	#has hit timeout
	will_stagger = false
	hit_started.emit()
	
func _die():
	animated_sprite.play("death")
	var heart = HeartPickup.instantiate()
	heart.position = Vector2(position.x, position.y-8)
	get_node("..").add_child(heart)
	queue_free()
	
func _attack(lunge_movement):
	if not getting_hit:
		animated_sprite.play("attack")
		attack_cooldown = 36
		lunge = lunge_movement

func _cast_meteor(player_velocity, player_position, ground_level):
	if attack_cooldown <= 0 and meteor_cooldown <= 0:
		animated_sprite.play("cast meteor")
		#instantiate meteor
		var meteor = Meteor.instantiate()
		var meteor_x = (player_velocity.x * 1) + player_position.x
		var meteor_y = ground_level
		meteor.position = Vector2(meteor_x, meteor_y)
		meteor.scale.x = 1 if animated_sprite.flip_h == false else -1
		get_node("..").add_child(meteor)
		print("cast meteor")
		meteor_cooldown = 36
