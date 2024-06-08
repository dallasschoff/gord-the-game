extends Node2D
class_name HealthComponent

@export var MAX_HEALTH := 30.0
var HEALTH : float

@export var healthbar_component : HealthBar

func _ready():
	HEALTH = MAX_HEALTH
	update_healthbar()

func damage(attack: Attack):
	HEALTH -= attack.attack_damage
	print("%s's Health: %s" % [get_owner().name, HEALTH])
	update_healthbar()
	if HEALTH <= 0:
		get_parent().queue_free()

func update_healthbar():
	healthbar_component.update(HEALTH)
