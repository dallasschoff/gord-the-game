extends Node2D
class_name Weapon

var attack_damage := 10.0
var knockback_force := 500.0
@export var attack_area: CollisionShape2D

func _on_hitbox_body_entered(area):
	if area is HurtboxComponent:
		var hurtbox: HurtboxComponent = area
		var attack = Attack.new()
		attack.attack_damage = attack_damage
		attack.knockback_force = knockback_force
		attack.attack_position = global_position
		
		hurtbox.damage(attack)

#Sprite:
# -hitbox: it deals damage to other sprites
# -hurtbox (aka its shape): receives damages if enters enemy hitbox?
