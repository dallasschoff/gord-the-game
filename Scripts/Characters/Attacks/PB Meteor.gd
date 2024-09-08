extends Node2D

@onready var meteor_sprite = $Meteor
@onready var explosion_sprite = $Explosion
var fade_timer
var fade_tween


func _on_meteor_animation_finished():
	meteor_sprite.visible = false
	explosion_sprite.visible = true
	explosion_sprite.play("explosion")

func _on_explosion_animation_finished():
	fade_timer = Timer.new()
	add_child(fade_timer)
	fade_timer.one_shot = true
	fade_timer.wait_time = 5
	fade_timer.connect("timeout", _on_fade_timer_timeout)
	fade_tween = get_tree().create_tween()
	fade_tween.parallel().tween_property(self, "modulate:a", 0, 5)
func _on_fade_timer_timeout():
	queue_free()

func _ready():
	print("meteor spawned")
	explosion_sprite.visible = false
	meteor_sprite.play("pb meteor")



