extends Node2D
class_name Weapon

@export var attack_damage := 10.0
@export var knockback_force := 30.0
var current_direction = "right"
@export var attack_area: CollisionPolygon2D

func _on_weapon_hitbox_entered(area):
	if area is HurtboxComponent:
		var hurtbox: HurtboxComponent = area
		
		var direction = global_position.direction_to(hurtbox.global_position)
		if (direction.x < 0):
			direction.x = clamp(direction.x, -1, -0.8)
		else:
			direction.x = clamp(direction.x, 0.8, 1)
		direction.y = clamp(direction.y, -0.4, 1)
		var knockback = direction * knockback_force
		var attack = Attack.new()
		attack.attack_damage = attack_damage
		attack.knockback = knockback
		
		hurtbox.damage(attack)

func change_direction(new_direction: String):
	current_direction = "left" if attack_area.scale.x > 0 else "right"
	
	if current_direction != new_direction:
		attack_area.scale.x = -attack_area.scale.x
