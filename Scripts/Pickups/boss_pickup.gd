extends AnimatedSprite2D

@onready var pickupArea: Area2D = $Area2D
@export var pickupValue: float = 50.0
var timer: Timer
var pickupScale = Vector2(2,2)
var scaleTime = 1.5


func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = scaleTime
	timer.one_shot = true
	timer.connect("timeout", _on_timer_timeout)
	timer.start()
	scale = Vector2(0,0)
	get_tree().create_tween().tween_property(self, "scale", pickupScale, scaleTime)

func _process(delta):
	play("spinning")

func _on_area_entered(area):
	if area is HurtboxComponent:
		var hurtbox: HurtboxComponent = area
		hurtbox.add_health(pickupValue)
		hide()
		pickupArea.get_child(0).set_deferred("disabled", false)
		await get_tree().create_timer(2).timeout
		SignalBus.boss_pickup_picked_up.emit()
		queue_free()
		
func _on_timer_timeout() -> void:
	pickupArea.get_child(0).set_deferred("disabled", false)
