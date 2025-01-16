extends Area2D
class_name HurtboxComponent

signal hitspark_signal 
@export var health_component : HealthComponent
@export var entity: CharacterBody2D

func damage(attack: Attack):
	if health_component:
		health_component.damage(attack)
	if entity:
		entity._hit(attack)

func add_health(healValue):
	if health_component:
		health_component.heal(healValue)
