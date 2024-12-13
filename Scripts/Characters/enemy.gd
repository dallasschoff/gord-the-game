extends CharacterBody2D

class_name Enemy

signal blocked
signal hit_started
signal hit_finished
signal attack_finished
signal increment_enemy_deaths

#Enemy trait values
var SPEED = 60
@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite = $AnimatedSprite2D
@export var raycasts: Node2D
@export var wall_raycast: RayCast2D
@export var floor_raycast: RayCast2D
@export var weapon: Weapon
@export var HeartPickup: PackedScene
#Animation traits
var hurting_cooldown = 0
var attack_cooldown = 0
var right_colliding = false
var left_colliding = false
var knockback = Vector2(0,0)
var tween
var lunge = Vector2(0,0)
var getting_hit = false
var gooning = false
var dead = false

func _physics_process(delta):
	if dead:
		return
	
	if gooning:
		animated_sprite.play("goon")
		return
		
	#Lunge tween and hitbox disabled bool based on animation frames
	if attack_cooldown > 0 and not getting_hit and not gooning:
		if animated_sprite.animation == "attack" and animated_sprite.frame == 5:
			velocity = lunge
		if animated_sprite.animation == "attack" and (animated_sprite.frame >= 5 and animated_sprite.frame <= 10):
			move_and_slide()
		if animated_sprite.animation == "attack" and (animated_sprite.frame >= 7 and animated_sprite.frame <= 8):
			weapon.attack_area.set_deferred("disabled", false)
		else:
			weapon.attack_area.set_deferred("disabled", true)
		attack_cooldown -= 1
		#Emit attack_finished once the attack_cooldown has reached 0
		if attack_cooldown == 0:
			attack_finished.emit()
		return
	
	velocity = velocity + knockback
	move_and_slide()
	
	if hurting_cooldown > 0:
		animated_sprite.play("hurting")
		hurting_cooldown -= 1
		return
	else:
		getting_hit = false
		hit_finished.emit()
	
	if abs(velocity.x) > 5:
		animated_sprite.play("walking")
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
		
func _look_left():
	weapon.change_direction("left")
	animated_sprite.flip_h = false
	raycasts.scale.x = 1

func _look_right():
	weapon.change_direction("right")
	animated_sprite.flip_h = true
	raycasts.scale.x = -1

func _hit(attack: Attack):
	getting_hit = true
	print("getting_hurt")
	hurting_cooldown = 30
	attack_cooldown = 0
	attack_finished.emit()
	knockback = attack.knockback
	
	tween = get_tree().create_tween()
	tween.parallel().tween_property(self, "knockback", Vector2(0,0), 0.5)
	hit_started.emit()
	
func _die():
	if dead:
		return
	animated_sprite.play("death")
	dead = true
	var heart = HeartPickup.instantiate()
	heart.position = Vector2(position.x, position.y-8)
	get_node("..").add_child(heart)
	
func _attack(lunge_movement):
	if not getting_hit and not gooning and not attack_cooldown > 0:
		animated_sprite.play("attack")
		attack_cooldown = 70
		lunge = lunge_movement
		
func _goon():
	gooning = true

func _on_animation_finished():
	if dead:
		increment_enemy_deaths.emit()
		queue_free()
