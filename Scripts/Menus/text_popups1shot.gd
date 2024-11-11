extends Area2D

@onready var animated_sprite = $"../.."
@onready var animation_player = $"../AnimationPlayer"

func _ready():
	animation_player.active = true
	animation_player.play("bobbing")
	animated_sprite.modulate = Color(1, 1, 1, 0)

func _on_body_entered(body):
	var fadeInTween = get_tree().create_tween()
	fadeInTween.parallel().tween_property(animated_sprite, "modulate", Color(1, 1, 1, 1), 0.5)
