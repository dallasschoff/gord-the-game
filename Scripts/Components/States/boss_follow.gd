extends State
class_name BossFollow

@export var boss: CharacterBody2D
@export var move_speed := 60
@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player: CharacterBody2D
var behavior: float
var wait_time: float
var follow = true
var can_meteor = false
var can_wall = false

func randomize_behavior():
	if follow:
		behavior = 5
	else:
		behavior = randi_range(0, 5)
		print("behavior: ",behavior)
	#Behavior values for meteor
	if behavior == 0 or behavior == 1: 
		can_wall = true
	#Behavior values for wall
	if behavior == 2:
		can_wall = true
	wait_time = 1

func enter():
	boss.connect("hit_started", _got_hurt)
	player = get_tree().get_first_node_in_group("Player")
	player.connect("died", _start_gooning)


func update(delta: float):
	if wait_time > 0:
		wait_time -= delta
	else:
		print("wait time expired")
		follow = !follow
		randomize_behavior()

func physics_update(delta: float):
	var direction = player.global_position - boss.global_position
	boss.velocity.y += gravity * delta
	#Defines length at which boss follows, else transitions to attack
	if direction.length() > 60:
		boss.velocity.x = direction.normalized().x * move_speed
		if can_meteor:
			boss._cast_meteor(player.velocity, player.position, player._get_ground_position())
			can_meteor = false
		if can_wall:
			boss._cast_wall(player.velocity, player.position, player._get_ground_position())
			can_wall = false
	
	else:
		transitioned.emit(self, "attack")
	
	#Defines length at which boss transitions to idle
	if direction.length() > 400:
		transitioned.emit(self, "idle")

func _on_animated_sprite_2d_animation_finished():
	if $"../../BossSprite".animation == "cast_meteor":
		wait_time = 0

func _got_hurt():
	transitioned.emit(self, "hurt")
	
func _start_gooning():
	var distance = player.global_position - boss.global_position
	if (distance.length() > 60):
		transitioned.emit(self, "goon")
