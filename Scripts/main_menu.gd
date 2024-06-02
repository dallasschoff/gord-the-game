extends Control

signal start_game

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
