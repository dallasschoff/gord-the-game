extends Area2D
class_name HurtboxComponent

@export var health_component : HealthComponent
@export var entity: CharacterBody2D

func damage(attack: Attack):
	if health_component:
		health_component.damage(attack)
	if entity:
		entity._hit(attack)

func add_health():
	if health_component:
		health_component.heal()
