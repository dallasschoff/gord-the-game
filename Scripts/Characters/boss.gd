extends CharacterBody2D

class_name Boss

signal blocked

#Enemy trait values
var SPEED = 60
@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite = $AnimatedSprite2D
@export var raycasts: Node2D
@export var wall_raycast: RayCast2D
@export var floor_raycast: RayCast2D
@export var weapon: Weapon
@export var HeartPickup: PackedScene
@export var Meteor: PackedScene
#Animation traits
var hurting_cooldown = 0
var attack_cooldown = 0
var is_idle
var is_walking
var right_colliding = false
var left_colliding = false
var knockback = Vector2(0,0)
var tween
var lunge = Vector2(0,0)


#func _process(delta):
	#if attack_cooldown > 0:

func _physics_process(delta):
	if attack_cooldown > 0:
		attack_cooldown -= 1
		if animated_sprite.animation == "attack" and (animated_sprite.frame >= 5 and animated_sprite.frame <= 10):
			move_and_slide()
		if animated_sprite.animation == "attack" and animated_sprite.frame == 5:
			tween = get_tree().create_tween()
			tween.parallel().tween_property(self, "lunge", Vector2(0,0), 2)
		if animated_sprite.animation == "attack" and (animated_sprite.frame >= 7 and animated_sprite.frame <= 9):
			weapon.attack_area.set_deferred("disabled", false)
		else:
			weapon.attack_area.set_deferred("disabled", true)
		return
	
	move_and_slide()
	
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
	
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _physics_process(delta):
	#move_character(delta)
	#_handle_animation_cooldowns()
	#is_walking = abs(velocity.x) > 10 and hurting_cooldown == 0
	#is_idle = abs(velocity.x) < 1 and !is_walking and hurting_cooldown == 0
	#if is_walking:
		#animated_sprite.play("walking")
	#if is_idle:
		#animated_sprite.play("idle")
#
#
# Handle moving enemy left and right on its own
#func move_character(delta):
	#if TARGET != null:
		#velocity.x = position.direction_to(TARGET.position).x * SPEED
		#velocity.y += GRAVITY * delta
		#velocity += knockback
		#move_and_slide()
		#if velocity.x < 0:
			#weapon.change_direction("left")
			#animated_sprite.flip_h = false
		#if velocity.x > 0:
			#weapon.change_direction("right")
			#animated_sprite.flip_h = true

func _hit(attack: Attack):
	is_walking = false
	is_idle = false
	hurting_cooldown = 36
	animated_sprite.play("hurting")
	print("Enemy hit")
	
	knockback = attack.knockback
	
	tween = get_tree().create_tween()
	tween.parallel().tween_property(self, "knockback", Vector2(0,0), 0.75)
	
func _die():
	animated_sprite.play("death")
	var heart = HeartPickup.instantiate()
	heart.position = Vector2(position.x, position.y-8)
	get_node("..").add_child(heart)
	queue_free()
	
func _attack(lunge_movement):
	animated_sprite.play("attack")
	attack_cooldown = 24
	lunge = lunge_movement

func _cast_meteor(player_velocity, player_position, ground_level):
	if attack_cooldown <= 0:
		animated_sprite.play("cast meteor")
		#instantiate meteor
		var meteor = Meteor.instantiate()
		var meteor_x = (player_velocity.x * 1) + player_position.x
		var meteor_y = (ground_level)
		meteor.position = Vector2(meteor_x, meteor_y)
		meteor.scale.x = 1 if animated_sprite.flip_h == false else -1
		get_node("..").add_child(meteor)
		print("cast meteor")
		attack_cooldown = 36
