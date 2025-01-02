extends TileMapLayer

@export var attack_damage := 10.0
@export var knockback_force := 30.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#if is_colliding():
		#
	#if area is HurtboxComponent:
		#var hurtbox: HurtboxComponent = area
		#
		#var direction = global_position.direction_to(hurtbox.global_position)
		#if (direction.x < 0):
			#direction.x = clamp(direction.x, -1, -0.8)
		#else:
			#direction.x = clamp(direction.x, 0.8, 1)
		#direction.y = clamp(direction.y, -0.4, 1)
		#var knockback = direction * knockback_force
		#var attack = Attack.new()
		#attack.attack_damage = attack_damage
		#attack.knockback = knockback
