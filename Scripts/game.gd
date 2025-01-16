extends Node2D
class_name Game

@export var WorldScene: PackedScene
@onready var transitioner = $CanvasLayer/Transitioner
var world: World
@onready var main_menu = $CanvasLayer/MainMenuComponent
@onready var end_screen = $CanvasLayer/EndScreen

var player_respawn : Vector2

func _ready():
	transitioner.connect("transition_finished", restart_game)
	main_menu.connect("restart_checkpoint", _update_checkpoint)
	SignalBus.boss_pickup_picked_up.connect(_end_screen)

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

func _update_checkpoint(checkpoint_location):
	player_respawn = checkpoint_location

func death_screen():
	transitioner.get_child(0).position.y = 440
	await get_tree().create_timer(2).timeout
	transitioner.play()
	
func restart_game():
	world.queue_free()
	transitioner._ready()
	main_menu.show()

func _end_screen():
	end_screen.show()
