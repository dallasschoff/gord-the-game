extends Node2D
class_name Weapon

@export var attack_damage := 10.0
@export var knockback_force := 30.0
var current_direction = "right"
@export var attack_area: CollisionShape2D

func _on_weapon_hitbox_entered(area):
	if area is HurtboxComponent:
		var hurtbox: HurtboxComponent = area
		
		var direction = global_position.direction_to(hurtbox.global_position)
		var knockback = direction * knockback_force
		var attack = Attack.new()
		attack.attack_damage = attack_damage
		attack.knockback = knockback
		
		hurtbox.damage(attack)

func change_direction(new_direction: String):
	current_direction = "right" if attack_area.position.x > 0 else "left"
	
	if current_direction != new_direction:
		attack_area.position.x = -attack_area.position.x
