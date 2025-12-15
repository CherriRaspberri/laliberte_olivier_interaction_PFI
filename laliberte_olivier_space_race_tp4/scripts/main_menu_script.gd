extends Control

#starts the game
func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

#quits the game
func _on_quit_pressed() -> void:
	get_tree().quit()
