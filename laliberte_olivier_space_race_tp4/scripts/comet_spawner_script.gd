extends Node

#Loads comet scene
var comet_scene = load("res://scenes/comet.tscn")

#difficulty variables
#stocks base constants for game resets
const DIF_INDEX_BASE: float = 1
const COMET_SPAWN_INT_BASE: float = 1
#assigns base to variables
var comet_spawn_interval = COMET_SPAWN_INT_BASE
var difficulty_index = DIF_INDEX_BASE

#spawns a comet on ready
func _ready() -> void:
	spawn_comet()

#Creates comet object
func spawn_comet():
	#Creates a new comet
	var comet = comet_scene.instantiate()
	#Gives the comet a random position
	set_comet_spawn_position(comet)
	#Gives the comet a random trajectory
	set_comet_trajectory(comet)
	#Adds it to the game
	add_child(comet)

#Sets comet spawn position
func set_comet_spawn_position(comet):
	#Grabs the screen size
	var screen = get_viewport().size
	#Sets the comet position at a random location on top of the screen
	comet.position = Vector2(randf_range(0, screen.x), -100)

#Sets comet trajectory
func set_comet_trajectory(comet):
	#Sets a random direction in which the comet will point to
	comet.angular_velocity = randf_range(-4, 4)
	#Removes angular damp
	comet.angular_damp = 0
	#Sets random vertical speed
	comet.linear_velocity = Vector2(randf_range(-300, 300), 100)
	#Removes angular damp
	comet.linear_damp = 0
	#Sets how fast the comets will fall down
	comet.gravity_scale = 0.3

#Spawns a new comet every second
func _on_spawn_timer_timeout() -> void:
	spawn_comet()

#restarts the spawn timer
func respawn_comets():
	$spawn_timer.stop()
	$spawn_timer.start()

#updates comet spawn frequency
func augment_difficulty():
	difficulty_index += 1
	comet_spawn_interval = 1 * pow(0.5, difficulty_index - 1)
	$spawn_timer.wait_time = max(comet_spawn_interval, 0.1)

#resets the difficulty
func reset_difficulty():
	comet_spawn_interval = COMET_SPAWN_INT_BASE
	difficulty_index = DIF_INDEX_BASE
	$spawn_timer.wait_time = comet_spawn_interval
