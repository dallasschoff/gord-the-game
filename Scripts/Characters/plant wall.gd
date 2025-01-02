extends CharacterBody2D

var dead: bool
@onready var animated_sprite =  $"Plant Wall"
@onready var hurtbox_component = $HurtboxComponent
@onready var health_component = $HealthComponent
var default = true
var default2 = true
var default3 = true

func _physics_process(delta: float) -> void:
	if not dead:
		health_component.heal(.3)
		if health_component.HEALTH >= 28 and default:
			animated_sprite.play("default")
		if health_component.HEALTH < 28 and health_component.HEALTH >= 10 and default2:
			animated_sprite.play("default2")
			default = false
		if health_component.HEALTH < 10:
			animated_sprite.play("default3")
			default2 = false

func _die():
	if dead:
		return
	animated_sprite.play("death")
	dead = true
	#Prevents hitsparks during the death animation
	hurtbox_component.set_collision_layer_value(3, false)
	set_collision_layer_value(4, false)
	set_collision_layer_value(1, false)
func _on_plant_wall_animation_finished() -> void:
	if animated_sprite.animation == "death":
		queue_free()
