extends Node2D

@export_enum("jump controls", "jump higher", "move controls", "eArrow") var text : String
@onready var animatedSprite2D = $AnimatedSprite2D

func _ready():
	if text == "":
		animatedSprite2D.play("jump higher")
	if text == "jump controls":
		animatedSprite2D.play("jump controls")
	if text == "jump higher":
		animatedSprite2D.play("jump higher")
	if text == "move controls":
		animatedSprite2D.play("move controls")
	if text == "eArrow":
		animatedSprite2D.play("eArrow")
