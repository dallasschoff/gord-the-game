extends CharacterBody2D

class_name Enemy

#Enemy trait values
var SPEED = 60 #60 pixels per sec
@onready var TARGET = $"../Player"
@onready var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite = $AnimatedSprite2D

@export var weapon: Weapon
#Animation traits
var hurting_cooldown = 0
var is_idle
var is_walking

var knockback = Vector2(0,0)
var knockbackTween

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	move_character(delta)
	_handle_animation_cooldowns()
	is_walking = abs(velocity.x) > 10 and hurting_cooldown ==0
	is_idle = abs(velocity.x) < 1 and !is_walking and hurting_cooldown == 0
	if is_walking:
		animated_sprite.play("walking")
	if is_idle:
		animated_sprite.play("idle")


# Handle moving en emy left and right on its own
func move_character(delta):
	if TARGET != null:
		velocity.x = position.direction_to(TARGET.position).x * SPEED
		velocity.y += GRAVITY * delta
		velocity += knockback
		move_and_slide()
		if velocity.x < 0:
			weapon.change_direction("left")
			animated_sprite.flip_h = false
		if velocity.x > 0:
			weapon.change_direction("right")
			animated_sprite.flip_h = true

#func _on_hurtbox_component_area_entered(area):
	#if area is Weapon:
		#is_walking = false
		#is_idle = false
		#hurting_cooldown = 36
		#animated_sprite.play("hurting")
		#print("Enemy hit")
		
func _hit(attack: Attack):
	is_walking = false
	is_idle = false
	hurting_cooldown = 36
	animated_sprite.play("hurting")
	print("Enemy hit")
	
	knockback = attack.knockback
	
	knockbackTween = get_tree().create_tween()
	knockbackTween.parallel().tween_property(self, "knockback", Vector2(0,0), 0.75)

func _handle_animation_cooldowns():
	if hurting_cooldown > 0:
		hurting_cooldown -= 1
