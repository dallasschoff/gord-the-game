extends Node2D

@onready var wall_sprite = $PBWallSprite


func _ready():
	wall_sprite.play("default")

#In SpriteFrames, we use the length of the animation to control how long the wall stays
func _on_pb_wall_sprite_animation_finished():
	queue_free()
