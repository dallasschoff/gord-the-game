extends CharacterBody2D

var dead: bool
@onready var animated_sprite =  $"Plant Wall"
@onready var hurtbox_shape = $"Plant Wall/HurtboxComponent/CollisionShape2D"
@onready var health_component = $HealthComponent

func _physics_process(delta: float) -> void:
	health_component.heal(.3)

func _die():
	if dead:
		return
	animated_sprite.play("death")
	dead = true
	#hurtbox_shape.disabled = true #Should* Prevents hitsparks during the death animation
	queue_free()
