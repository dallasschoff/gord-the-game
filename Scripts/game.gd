extends Node2D
class_name Game

@export var WorldScene: PackedScene
@onready var transitioner = $CanvasLayer/Transitioner
var world: World
@onready var main_menu = $CanvasLayer/MainMenuComponent

var player_respawn : Vector2

func _ready():
	transitioner.connect("transition_finished", restart_game)
	main_menu.connect("restart_checkpoint", _update_checkpoint)

func start_game():
	world = WorldScene.instantiate()
	add_child(world)
	move_child(world, 0)
	world.get_node("Player").connect("died", death_screen)
	if player_respawn != Vector2(0,0):
		world.get_node("Player").global_position = player_respawn
	world.get_node("Checkpoint").connect("update_checkpoint", _update_checkpoint)
	world.get_node("Checkpoint2").connect("update_checkpoint", _update_checkpoint)
	world.get_node("Checkpoint3").connect("update_checkpoint", _update_checkpoint)
	#world.get_node("Player").position

func _update_checkpoint(checkpoint_location):
	player_respawn = checkpoint_location

func death_screen():
	await get_tree().create_timer(2).timeout
	transitioner.play()
	
func restart_game():
	world.queue_free()
	transitioner._ready()
	main_menu.show()
