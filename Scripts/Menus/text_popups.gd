extends Node2D

@onready var animated_sprite = $"../AnimationPlayer/AnimatedSprite2D"
@onready var animation_player = $"../AnimationPlayer"

func _ready():
	animated_sprite.visible = true
	animation_player.play("bobbing")

func _on_body_entered(body):
	animation_player.play("fade_in")
	animated_sprite.visible = true

func _on_body_exited(body):
	animation_player.play("fade_out")
	animated_sprite.visible = true
