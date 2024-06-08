extends Node2D
class_name Weapon

@export var attack_damage := 10.0
var knockback_force := 1000.0
var current_direction = "right"
@export var attack_area: CollisionShape2D

func _on_weapon_hitbox_entered(area):
	if area is HurtboxComponent:
		var hurtbox: HurtboxComponent = area
		var attack = Attack.new()
		attack.attack_damage = attack_damage
		attack.knockback_force = knockback_force
		attack.attack_position = global_position
		
		hurtbox.damage(attack)

func change_direction(new_direction: String):
	current_direction = "right" if attack_area.position.x > 0 else "left"
	
	if current_direction != new_direction:
		attack_area.position.x = -attack_area.position.x
