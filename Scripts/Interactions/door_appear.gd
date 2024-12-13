extends Node2D

@onready var animated_sprite = $AnimatedSprite2D
var door = load("res://Scenes/Interactions/Door.tscn")
@export_enum("kill 1 enemy") var condition : String
var world: World
var fired = false
@export var teleport_position : Vector2

func _ready():
	animated_sprite.play("default")
	world = get_parent()

func _process(delta):
	_check()

func _check():
	if !fired:
		if condition == "":
			pass
		if condition == "kill 1 enemy":
			if world.enemy_deaths == 1:
				fired = true
				animated_sprite.play("door appear")

func _on_animated_sprite_2d_animation_finished():
	var instance = door.instantiate()
	get_parent().add_child(instance)
	instance.position = position
	instance.teleport_position = teleport_position
	queue_free()
