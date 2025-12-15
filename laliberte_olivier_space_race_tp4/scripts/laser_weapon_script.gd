extends Node2D

#imports laser object
var laser_object = load("res://scenes/laser.tscn")

#shoots a laser
func shoot():
	#creates a new laser
	var laser = laser_object.instantiate()
	#sets the base pos of the laser based on the weapon (current node)
	laser.global_position = self.global_position
	
	#adds the laser as a child of the game instead of the player
	get_node("/root/Game").add_child(laser)
	
	#plays the sound
	play_sound(laser)

#plays a laser sound 
func play_sound(laser_object):
	#loads the sound scene and creates a new object
	var laser_sound_scene = load("res://scenes/laser_sound.tscn")
	var laser_sound = laser_sound_scene.instantiate()
	#adds it to the weapon
	get_tree().current_scene.add_child(laser_sound)
	#the separation of the sound and the laser object makes it so it plays entirely 
	#and doesn't stop when the laser object is removed
