extends Area2D

@onready var animated_sprite = $"../AnimatedSprite2D"

func _ready():
	pass

func _on_body_entered(body):
	animated_sprite.play("doorblip")

func _on_animated_sprite_2d_animation_finished():
	queue_free()
