extends Sprite2D

@export var heartArea: Area2D

func _on_area_entered(area):
	if area is HurtboxComponent:
		var hurtbox: HurtboxComponent = area
		hurtbox.add_health()
		queue_free()
