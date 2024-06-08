class_name HealthBar
extends TextureProgressBar

var HEALTH

func _process(delta):
	value = HEALTH

func update(health):
	HEALTH = health
	print("Updating health for %s" % get_owner().name)
