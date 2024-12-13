extends Control
class_name MainMenu

signal start_game
signal restart_checkpoint

@onready var buttonsVBox: VBoxContainer = %ButtonsVBox

func _ready():
	focus_button()

func _on_start_game_button_pressed():
	start_game.emit()
	hide()

func _on_quit_button_pressed():
	get_tree().quit()

func _on_visibility_changed():
	if visible:
		focus_button()

func focus_button():
	if buttonsVBox:
		var button: Button = buttonsVBox.get_child(0)
		if button is Button:
			button.grab_focus()

func _on_restart_button_pressed():
	#This is supposed to force the respawn position, but isn't working as intended
	restart_checkpoint.emit(Vector2(338,110)) #Connects to Game_0.gd
	start_game.emit()
	hide()
