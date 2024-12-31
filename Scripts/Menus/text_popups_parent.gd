extends Node2D

@export_enum("jump controls", "jump higher", "move controls", "eArrow", \
"attack controls", "combo attack", "combo attack controls1", "combo attack controls2", "plus")\
var text : String

@onready var animatedSprite2D = $AnimatedSprite2D

func _ready():
	animatedSprite2D.play(text)
