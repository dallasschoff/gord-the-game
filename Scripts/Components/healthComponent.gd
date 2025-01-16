extends Node2D
class_name HealthComponent

@export var MAX_HEALTH := 30.0
var HEALTH : float

@export var healthbar_component : HealthBar
@export var entity: CharacterBody2D
@export var animated_sprite: AnimatedSprite2D

func _ready():
	HEALTH = MAX_HEALTH
	healthbar_component.value = HEALTH
	healthbar_component.max_value = MAX_HEALTH
	update_healthbar()

func damage(attack: Attack):
	HEALTH -= attack.attack_damage
	update_healthbar()
	print("%s's Health: %s" % [get_parent().name, HEALTH])
	if HEALTH <= 0:
		entity._die()
	
func heal(healValue):
	if (HEALTH < MAX_HEALTH):
		HEALTH += healValue
		if HEALTH > MAX_HEALTH: 
			HEALTH = MAX_HEALTH
			print("Max health reached, no overheal")
		update_healthbar()
	#Color effects
	animated_sprite.modulate = Color.GREEN
	await get_tree().create_timer(0.4).timeout
	animated_sprite.modulate = Color.WHITE
	#print("%s's Health: %s" % [get_parent().name, HEALTH])

func update_healthbar():
	healthbar_component.update(HEALTH)
