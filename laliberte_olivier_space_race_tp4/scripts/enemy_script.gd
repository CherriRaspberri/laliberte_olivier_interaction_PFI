extends Node2D

#fetches explosion particles
var explosion_particles_scene = load("res://scenes/enemy_explosion_particles.tscn")
#fetches camera
@onready var camera = get_node("/root/Game/Camera2D")
#fetches laser
var laser_scene = preload("res://scenes/laser_enemy.tscn")

#enemy variables
const RAY_LENGTH = 400
var speed = 400
var target: Node2D = null
const START_HEALTH = 30
var health = START_HEALTH

var faster_shoot = false
var is_exploded = false
@onready var enemy_sprite = $Sprite2D
@onready var ray_cast = $RayCast2D
@onready var reload_timer = $RayCast2D/reload_timer

#PathFollow is the parent of enemy
@onready var path_follow: PathFollow2D = get_parent() as PathFollow2D

#finds target on ready
func _ready() -> void:
	target = find_target()
	ray_cast.enabled = true

#moves and rotates every frame
func _physics_process(delta: float) -> void:
	#follows the path given
	if path_follow:
		path_follow.progress += speed * delta
		if path_follow.progress > 1.0:
			path_follow.progress -= 1.0
	
	#always checks if there is a valid target; if none, find one
	if target == null or not is_instance_valid(target):
		target = find_target()
	if target == null:
		return

	#rotates the enemy to always face the player
	var dir = global_position.direction_to(target.global_position)
	rotation = dir.angle() + -PI / 2

	ray_cast.force_raycast_update()

	#if player is in range, shoot it
	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		if collider.is_in_group("Player") and reload_timer.is_stopped():
			$laser_sound.play()
			shoot()

#Shoots a laser
func shoot():
	ray_cast.enabled = false
	#creates a new laser
	var laser = laser_scene.instantiate()
	laser.global_position = global_position
	laser.global_rotation = global_rotation
	get_tree().current_scene.add_child(laser)
	#Gives the shoot function a cooldown
	reload_timer.start()

#Finds the player (on player spawn)
func find_target():
	var new_target: Node2D = null
	#Searches tree for player node
	if get_tree().has_group("Player"):
		new_target = get_tree().get_nodes_in_group("Player")[0]
	#returns the new player
	return new_target

#resets the shoot cooldown
func _on_reload_timer_timeout() -> void:
	ray_cast.enabled = true

#updates health: if above zero, count down; else, kill the enemy
func update_health():
	if health > 0:
		#updates health
		health = health - 1
		#if health is below 15, shoot faster
		if health <= 15 and !faster_shoot:
			faster_shoot = true
			$RayCast2D/reload_timer.wait_time = 0.5
	else:
		explode()

#explodes on death
func explode():
	#Checks if function has already been called;
	#If it has, don't free the queue
	#This prevents a glitch where 2 lasers collide with the same comet
	if is_exploded:
		return
	#Turns on the boolean
	is_exploded = true
	#spawns the particles
	spawn_explosion_particles()
	#plays the explosion sound
	play_sound()
	#shakes the screen
	camera.random_strength = 30
	camera.apply_shake()
	#Removes the enemy from the game
	remove_from_group("Enemy")
	get_parent().remove_child(self)
	queue_free()

#spawns explosion particles
func spawn_explosion_particles():
	#instantiates the particles scene
	var particles = explosion_particles_scene.instantiate()
	#sets the position to the same position as the enemy
	particles.position = self.position
	#adds it to the scene tree
	get_parent().add_child(particles)
	#emits particles
	particles.emitting = true

#plays death sound 
func play_sound():
	#loads the enemy sound scene
	var enemy_sound_scene = load("res://scenes/enemy_sound.tscn")
	var enemy_sound = enemy_sound_scene.instantiate()
	#adds it to the scene
	get_tree().current_scene.add_child(enemy_sound)

#resets enemy health
func reset_health():
	#stops the faster shooting
	faster_shoot = false
	$RayCast2D/reload_timer.wait_time = 1
	#resets health to 100%
	health = START_HEALTH
