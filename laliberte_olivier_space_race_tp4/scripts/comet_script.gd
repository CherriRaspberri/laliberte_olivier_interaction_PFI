extends RigidBody2D

#fetches explosion particles
var explosion_particles_scene = load("res://scenes/comet_explosion_particles.tscn")
#fetches small comet scene
var comet_small_scene = load("res://scenes/comet_small.tscn")
#fetches score visual scene
var score_scene = load("res://scenes/score_value.tscn")

#fetches camera
@onready var camera = get_node("/root/Game/Camera2D")

var rand = RandomNumberGenerator.new()
var is_exploded = false

#screen limits (a bit more than the screen size so the comets don't disappear while still shown
const LEFT_LIMIT = -20
const RIGHT_LIMIT = 1300
const BOTTOM_LIMIT = 740

#score imports
#sound signal
var comet_type: String = "big"
#score value signal
signal score_change(value: int)
@onready var score = get_node("/root/Game/CanvasLayer/GUI/MarginContainer/HBoxContainer/score")
var score_value: int = 100

func _ready() -> void:
	self.connect("score_change", Callable(score, "update_score"))

func _process(delta: float) -> void:
	#checks every frame if comet is OOB; if it is, remove it
	if is_out_of_bounds():
		queue_free()

#On contact with a laser, gets removed from the game
func explode():
	#Checks if function has already been called;
	#If it has, don't free the queue
	#This prevents a glitch where 2 lasers collide with the same comet
	if is_exploded:
		return
	#Turns on the boolean
	is_exploded = true
	#spawns the particles
	spawn_explosion_particles(2)
	#plays the explosion sound
	play_sound()
	#shakes the screen
	camera.random_strength = 10
	camera.apply_shake()
	#changes the score
	emit_signal("score_change", score_value)
	#shows the score gained
	spawn_score()
	#spawns a random amount of smaller comets (between 2 and 4)
	spawn_comets(randf_range(2, 5))
	#Removes the comet from the game
	get_parent().remove_child(self)
	queue_free()

#shows the score gained by destroying the comet
func spawn_score():
	#instantiates the scene
	var score_points = score_scene.instantiate()
	#sets the score text to its value
	score_points.get_node("Label").text = str(score_value)
	#sets the position
	score_points.position = self.position
	#adds the scene to the tree
	get_parent().add_child(score_points)
	#plays sound according to its type
	score_points.emit_sound(comet_type)

#spawns multiple instances of the small comet
func spawn_comets(num: int):
	for i in range(num):
		spawn_comet_small()

#spawns the particles for the explosion
func spawn_explosion_particles(size: int):
	#instantiates the particles scene
	var particles = explosion_particles_scene.instantiate()
	#sets the position to the same position as the comet
	particles.position = self.position
	#sets the scale of the explosion
	particles.scale = Vector2(size, size)
	#adds it to the scene tree
	get_parent().add_child(particles)
	#emits particles
	particles.emitting = true

#plays the sound 
func play_sound():
	#loads the comet sound scene
	var comet_sound_scene = load("res://scenes/comet_sound.tscn")
	var comet_sound = comet_sound_scene.instantiate()
	#adds it to the weapon
	get_tree().current_scene.add_child(comet_sound)

#spawns smaller comets on impact
func spawn_comet_small():
	#creates a new small comet
	var comet_small = comet_small_scene.instantiate()
	#sets the new comets position to the big one 
	comet_small.position = self.position
	#sets the trajectory for the smaller comets
	set_comet_small_trajectory(comet_small)
	#adds the new small comet to the scene tree
	get_parent().add_child(comet_small)

#sets a random trajectory for the smaller comets
func set_comet_small_trajectory(comet):
	#Sets a random direction in which the comet will point to
	comet.angular_velocity = randf_range(-4, 4)
	#Removes angular damp
	comet.angular_damp = 0
	#sets a random int number between -1, 0 and 1
	rand.randomize()
	var lin_vel_x = rand.randi_range(-1, 1)
	var lin_vel_y = rand.randi_range(-1, 1)
	#Sets random vertical speed by applying our random numbers and multiplying it to the regular velocity
	comet.linear_velocity = Vector2(randf_range(lin_vel_x * -300, lin_vel_y * 300), 100)
	#Removes angular damp
	comet.linear_damp = 0
	#Sets how fast the comets will fall down
	comet.gravity_scale = 0.3

#checks if comet is OOB; returns true if it is
func is_out_of_bounds() -> bool:
	return (position.x < LEFT_LIMIT or position.x > RIGHT_LIMIT or position.y > BOTTOM_LIMIT)
