extends Area2D
signal hitspark_signal

@export var attack_damage := 1.0
@export var knockback_force := 30.0

@onready var hurtbox = $"../HurtboxComponent"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#Environmental hazards
func _on_body_entered(body: Node2D) -> void:
	if body is EnvironmentalHazard:
		var tile_position = (body.map_to_local(global_position)/ 32) - Vector2(4,4)
		var direction = global_position - (tile_position)
		print("tile_position, ", tile_position)
		print("global_position, ", global_position)
		print("direction, ", direction)
		if (direction.x < 0):
			direction.x = clamp(direction.x, -1, -0.8)
		else:
			direction.x = clamp(direction.x, 0.8, 1)
		direction.y = clamp(direction.y, -0.4, 0)
		var knockback = direction * knockback_force
		var attack = Attack.new()
		attack.attack_damage = attack_damage
		attack.knockback = knockback
		hitspark_signal.emit() #connects to hitspark.gd
		hurtbox.damage(attack)
