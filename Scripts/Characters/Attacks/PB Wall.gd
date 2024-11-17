extends Node2D

@onready var wall_sprite = $PBWallSprite

func _ready():
	wall_sprite.play("default")
