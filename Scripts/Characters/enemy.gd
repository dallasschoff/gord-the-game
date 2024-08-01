extends CharacterBody2D

class_name Enemy

signal blocked
signal hit_started
signal hit_finished

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

func _physics_process(delta):
	if attack_cooldown > 0 and hurting_cooldown == 0:
		if animated_sprite.animation == "attack" and (animated_sprite.frame >= 5 and animated_sprite.frame <= 10):
			move_and_slide()
		if animated_sprite.animation == "attack" and animated_sprite.frame == 5:
			tween = get_tree().create_tween()
			tween.parallel().tween_property(self, "lunge", Vector2(0,0), 2)
		if animated_sprite.animation == "attack" and (animated_sprite.frame >= 7 and animated_sprite.frame <= 9):
			weapon.attack_area.set_deferred("disabled", false)
		else:
			weapon.attack_area.set_deferred("disabled", true)
		attack_cooldown -= 1
		return
	
	velocity = velocity + knockback
	move_and_slide()
	
	if hurting_cooldown > 0:
		print("getting_hurt")
		animated_sprite.play("hurting")
		hurting_cooldown -= 1
		return
	else:
		getting_hit = false
		hit_finished.emit()
	
	if abs(velocity.x) > 0:
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

func _hit(attack: Attack):
	getting_hit = true
	hit_started.emit()
	hurting_cooldown = 30
	knockback = attack.knockback
	print(knockback)
	
	tween = get_tree().create_tween()
	tween.parallel().tween_property(self, "knockback", Vector2(0,0), 0.5)
	
func _die():
	animated_sprite.play("death")
	var heart = HeartPickup.instantiate()
	heart.position = Vector2(position.x, position.y-8)
	get_node("..").add_child(heart)
	queue_free()
	
func _attack(lunge_movement):
	if not getting_hit:
		animated_sprite.play("attack")
		attack_cooldown = 24
		lunge = lunge_movement
