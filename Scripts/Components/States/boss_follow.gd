extends State
class_name BossFollow

@export var boss: CharacterBody2D
@export var move_speed := 60
@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player: CharacterBody2D
var behavior: float
var wait_time: float
var follow = true
var can_attack = false

func randomize_behavior():
	if follow:
		behavior = 1
	else:
		behavior = randi_range(-1, 1)
		print("behavior: ",behavior)
	if behavior == 0: 
		can_attack = true
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
		if can_attack:
			boss._cast_meteor(player.velocity, player.position, player._get_ground_position())
			can_attack = false
	
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
