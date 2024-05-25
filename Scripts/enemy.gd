extends CharacterBody2D

class_name Enemy

signal attack
signal healthChanged

#Enemy trait values
@export var MAX_HEALTH = 100
@onready var CURRENT_HEALTH: int = MAX_HEALTH
var SPEED = 30 #30 pixels per sec
@onready var TARGET = $"../Player"
@onready var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var enemy_attack_area = $AttackArea
var hit_cooldown = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	healthChanged.emit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_character(delta)
	attack_player()
	
# Handle moving character left and right on its own
func move_character(delta):
	if TARGET != null:
		velocity.x = position.direction_to(TARGET.position).x * SPEED
		velocity.y += GRAVITY * delta
		move_and_slide()
		
func attack_player():
	hit_cooldown -= 1
	if enemy_attack_area.has_overlapping_areas() and hit_cooldown <= 0:
		attack.emit()
		hit_cooldown = 150
		print("hit player!")

func hit_by_player():
	CURRENT_HEALTH -= 10
	healthChanged.emit()
