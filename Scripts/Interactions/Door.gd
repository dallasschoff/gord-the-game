extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@export var teleport_position: Vector2
@onready var player = $"../Player"

func _ready():
	interaction_area.interact = Callable(self, "_on_interact")
	pass

func _on_interact():
	print("door interacted")
	#await get_tree().create_timer(0.1).timeout
	player.position = teleport_position
	queue_free()
