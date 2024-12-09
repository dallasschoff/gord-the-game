extends Node2D
class_name World

# This is here so the boss knows the limits of where it can cast spells on this screen
# Otherwise spells could get cast into the walls
var boss_room_left : int = 7274
var boss_room_right : int = 8348

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_checkpoint_2_update_checkpoint():
	pass # Replace with function body.
