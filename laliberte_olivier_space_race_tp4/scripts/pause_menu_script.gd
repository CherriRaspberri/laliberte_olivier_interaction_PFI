extends Control

@onready var main = $"../../"

#when resume is pressed, continue the game
func _on_resume_pressed() -> void:
	main.show_pause_menu()

#when quit button is pressed, close the game
func _on_quit_pressed() -> void:
	get_tree().quit()
