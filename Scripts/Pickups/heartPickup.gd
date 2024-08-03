extends AnimatedSprite2D

@export var heartArea: Area2D
var timer: Timer

func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.8
	timer.one_shot = true
	timer.connect("timeout", _on_timer_timeout)
	timer.start()
	scale = Vector2(0,0)
	get_tree().create_tween().tween_property(self, "scale", Vector2(1,1), 0.75)

func _process(delta):
	play("spinning")

func _on_area_entered(area):
	if area is HurtboxComponent:
		var hurtbox: HurtboxComponent = area
		hurtbox.add_health()
		queue_free()
		
func _on_timer_timeout() -> void:
	heartArea.get_child(0).set_deferred("disabled", false)
