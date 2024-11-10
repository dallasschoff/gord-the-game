extends AnimatedSprite2D

@export var heartArea: Area2D
@export var healValue: float = 10.0
var timer: Timer
var heartScale = Vector2(1,1)
var scaleTime = 0.75

func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = scaleTime
	timer.one_shot = true
	timer.connect("timeout", _on_timer_timeout)
	timer.start()
	scale = Vector2(0,0)
	get_tree().create_tween().tween_property(self, "scale", heartScale, scaleTime)

func _process(delta):
	play("spinning")

func _on_area_entered(area):
	if area is HurtboxComponent:
		var hurtbox: HurtboxComponent = area
		hurtbox.add_health(healValue)
		queue_free()
		
func _on_timer_timeout() -> void:
	heartArea.get_child(0).set_deferred("disabled", false)
