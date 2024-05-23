extends CharacterBody2D

class_name GravityPlayer

const WALK_FORCE = 600
const WALK_MAX_SPEED = 200
const STOP_FORCE = 1000
const JUMP_SPEED = 300

@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta):
	# Horizontal movement code. First, get the player's input.
	var walk = WALK_FORCE * (Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
	# Flips player sprite based on left and right inputs.
	if Input.get_action_strength("move_left"):
		animated_sprite.flip_h = true
	if Input.get_action_strength("move_right"):
		animated_sprite.flip_h = false
	
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

#ATTACKING WIP
var damage = 0
# Attack cooldown and state
var can_attack = true
var attack_cooldown = 1.0 # seconds
var attack_duration = 0.2 # seconds

# Reference to the AttackArea
@onready var attack_area = $AttackArea

# Signal for when the attack hits something
signal attack_hit(target)

func _ready():
	# Connect the area_entered signal of the AttackArea
	attack_area.connect("area_entered", self, "_on_AttackArea_area_entered")
	# Initially disable the attack area
	attack_area.disabled = true

# New function to handle the attack timing using async/await
func attack():
	if can_attack:
		can_attack = false
		attack_area.disabled = false
		$AnimationPlayer.play("attack") # Assuming you have an AnimationPlayer for attacking
		await get_tree().create_timer(attack_duration).timeout
		attack_area.disabled = true
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true

func _on_AttackArea_area_entered(area):
	if area.is_in_group("enemies"): # Assuming enemies are in the "enemies" group
		emit_signal("attack_hit", area)
		# Handle dealing damage to the enemy
		area.take_damage(damage)

# Example function for enemies to take damage
func take_damage(damage):
	health -= damage
	if health <= 0:
		die()

func die():
	queue_free() # Or any other death logic
