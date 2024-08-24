extends Node2D

@onready var meteor_sprite = $Meteor
@onready var explosion_sprite = $Explosion

func _on_meteor_animation_finished():
	meteor_sprite.visible = false
	explosion_sprite.visible = true
	explosion_sprite.play("explosion")
	
