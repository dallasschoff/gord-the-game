class_name HealthBar
extends TextureProgressBar

var HEALTH
var tween

func update(health): 
	var difference = health - value
	var chunk = difference * 0.75
	var slow = difference * 0.25
	value += chunk
	tween = get_tree().create_tween()
	tween.parallel().tween_property(self, "value", value + slow, 0.5)
	print("Updating health for %s" % get_owner().name)
