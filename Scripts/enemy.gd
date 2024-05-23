extends CharacterBody2D

#Enemy trait values
var SPEED = 30 #30 pixels per sec
@onready var TARGET = $"../GravityPlayer"
@onready var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_character(delta)
	
# Handle moving character left and right on its own
func move_character(delta):
	if TARGET != null:
		velocity.x = position.direction_to(TARGET.position).x * SPEED
		velocity.y += GRAVITY * delta
		move_and_slide()
