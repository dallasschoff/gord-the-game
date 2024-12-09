extends Node2D
class_name Checkpoint

@export var checkpoint_location: Vector2
var checkpoint_got = false

signal update_checkpoint

func _ready():
	pass

func _on_area_2d_body_entered(body):
	print("checkpoint got!")
	if checkpoint_got == false:
		checkpoint_got = true
		update_checkpoint.emit(checkpoint_location)


func _on_update_checkpoint():
	pass # Replace with function body.
