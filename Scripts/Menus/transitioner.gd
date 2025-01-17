extends Control
class_name Transitioner

signal transition_finished

@export var scene_to_load: PackedScene
@onready var animation_text: TextureRect = $TextureRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	visible = false
	animation_text.visible = false

func play():
	visible = true
	animation_player.play("fade_out")

func _on_animation_player_animation_finished(anim_name):
	if scene_to_load:
		transition_finished.emit()

#For screen transition when going through doors
#func _on_animation_player_animation_finished(anim_name):
	#if anim_name == ("fade_out"):
		#animation_player.play("fade_in")
	#if anim_name == ("fade_in"):
		#texturerect.visible = false
	#else:
		#pass
