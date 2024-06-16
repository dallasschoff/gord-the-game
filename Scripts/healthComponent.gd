extends Node2D
class_name HealthComponent

@export var MAX_HEALTH := 30.0
var HEALTH : float

@export var healthbar_component : HealthBar
@export var entity: CharacterBody2D

func _ready():
	HEALTH = MAX_HEALTH
	update_healthbar()

func damage(attack: Attack):
	HEALTH -= attack.attack_damage
	update_healthbar()
	print("%s's Health: %s" % [get_owner().name, HEALTH])
	if HEALTH <= 0 and entity:
		entity._die()
	
func heal():
	if (HEALTH < MAX_HEALTH):
		HEALTH += 10
		update_healthbar()
	print("%s's Health: %s" % [get_owner().name, HEALTH])

func update_healthbar():
	healthbar_component.update(HEALTH)
