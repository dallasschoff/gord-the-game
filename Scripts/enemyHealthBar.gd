extends TextureProgressBar

@export var enemy: Enemy

# Called when the node enters the scene tree for the first time.
func _ready():
	enemy.healthChanged.connect(update)
	update()
	
func update():
	value = enemy.CURRENT_HEALTH * 100 / enemy.MAX_HEALTH
