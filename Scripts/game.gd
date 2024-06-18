extends Node2D
class_name Game

@export var WorldScene: PackedScene
@onready var transitioner = $CanvasLayer/Transitioner
var world: World

func _ready():
	transitioner.connect("transition_finished", restart_game)

func start_game():
	world = WorldScene.instantiate()
	add_child(world)
	move_child(world, 0)
	world.get_node("Player").connect("died", death_screen)

func death_screen():
	transitioner.play()
	
func restart_game():
	get_tree().reload_current_scene()
