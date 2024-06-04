extends Node2D
class_name Game

@export var WorldScene: PackedScene
@export var PlayerScene: PackedScene
@export var EnemyScene: PackedScene

var world: World
var player: Player
var enemy: Enemy

func start_game():
	world = WorldScene.instantiate()
	add_child(world)
	move_child(world, 0)
	
	player = PlayerScene.instantiate()
	player.position = Vector2(600, 150)
	world.add_child(player)
	
	enemy = EnemyScene.instantiate()
	enemy.position = Vector2(700, 150)
	world.add_child(enemy)
	
func _on_main_menu_component_start_game():
	start_game()
