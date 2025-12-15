extends CharacterBody2D

#camera import 
#explosion scene import
var explosion_scene = load("res://scenes/player_explosion_particles.tscn")
#controls how fast the player moves
const SPEED = 500

var min_x = 40
var max_x = 1240

signal player_died

#creates player signals when this scene is instantiated
func _ready() -> void:
	var camera

#player movement
func _physics_process(delta: float) -> void:
	#defines player movement
	var velocity = Vector2() 
	
	#makes the player clamped inside those coordinates
	position.x = clamp(position.x, min_x, max_x)
	
	#depending on what key the user presses, adjust velocity accordingly
	if (Input.is_action_pressed("move_left")):
		velocity.x = -SPEED
	if (Input.is_action_pressed("move_right")):
		velocity.x = SPEED
	
	#moves the player
	var collision = move_and_collide(velocity * delta)
	
	#checks if there is a collision with the walls;
	#if there is, remove the player
	if collision:
		var collider = collision.get_collider()
		if collider.is_in_group("walls"):
			explode()

#player shoot
func _unhandled_key_input(event: InputEvent) -> void:
	#if the player presses the shoot button, shoot a laser
	if (event.is_action_pressed("shoot")):
		$laser_weapon.shoot()

#player hit
func _on_hitbox_body_entered(body: Node2D) -> void:
	if (!self.is_queued_for_deletion() && body.is_in_group("comets")):
		explode()

#on hit, explode
func explode():
	#adjusts the camera
	var camera = get_node("/root/Game/Camera2D")
	camera.focus_on_main()
	#instantiates the explosion
	var explosion = explosion_scene.instantiate()
	#gives the same position as the player
	explosion.position = self.position
	#adds the explosion to the current scene
	get_parent().add_child(explosion)
	explosion.emitting = true
	#signals that the player died
	emit_signal("player_died")
	#removes the player
	queue_free()

#enables/disables the hitbox (when the level is completed, for example)
func disable_hitbox(disabled: bool):
	#if disabled, remove hitbox; if not, activate it
	if disabled:
		$hitbox/CollisionShape2D.disabled = true
	else:
		$hitbox/CollisionShape2D.disabled = false
