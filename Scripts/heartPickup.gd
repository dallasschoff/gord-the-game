extends AnimatedSprite2D

@export var heartArea: Area2D

func _ready():
	scale = Vector2(0,0)
	get_tree().create_tween().tween_property(self, "scale", Vector2(1,1), 0.75)

func _process(delta):
	play("spinning")

func _on_area_entered(area):
	if area is HurtboxComponent:
		var hurtbox: HurtboxComponent = area
		hurtbox.add_health()
		queue_free()
