extends Camera2D

#sets who the camera will follow
@export var player_path: NodePath = NodePath("")
#sets the game window size
@export var game_size: Vector2 = Vector2(1280, 720)
#sets camera properties
@export var camera_zoom: Vector2 = Vector2(1.375, 1.375)
@export var camera_offset: Vector2 = Vector2(0, -10)
#variable instancing for the player
var target: Node2D
var is_following = true

#shake exports
@export var random_strength: float = 30
@export var shake_fade: float = 5
var rng = RandomNumberGenerator.new()
var shake_strength = 0

#fetches the player on ready
func _ready() -> void:
	#makes this the main camera
	make_current()
	#applies camera properties
	zoom = Vector2(1, 1)
	offset = Vector2.ZERO
	
	#fetches player path to target
	if player_path != NodePath():
		target = get_node_or_null(player_path)
	await get_tree().process_frame
	
	#if target is valid, give it a position and follow the player
	if is_instance_valid(target):
		#sets the position
		position = target.global_position
		await get_tree().process_frame
		#sets the camera to follow the player
		focus_on_player()

func _process(delta: float) -> void:
	#checks if the screen is shaking
	#if it is, decrease the shake until there is no shake
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0 , shake_fade * delta)
		offset = random_offset()
	
	#sets the camera's position to the player
	if is_following and is_instance_valid(target):
		position = target.global_position

func apply_shake():
	shake_strength = random_strength

#gives a random offset to the screen shake
#limits are the strength passed
func random_offset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))

#will focus on the main when the player dies
func focus_on_main():
	#sets following the player to false
	is_following = false
	#removes any camera settings
	#resets the offset
	offset = Vector2.ZERO
	
	#smooth transitions
	#fetches the center of the game
	var target_position = game_size / 2
	
	#Always tween the zoom
	#if camera is already centered, tween only the zoom
	#if not, tween the position
	if position.distance_to(target_position) > 1:
		#new position tween
		var tween = create_tween()
		tween.tween_property(self, "position", target_position, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	else:
		position = target_position
	
	#fetches the viewport size
	var viewport_size = get_viewport_rect().size
	#fetches the zoom factor
	var zoom_factor = game_size / viewport_size
	#creates a vector that has the size where I ant to zoom
	var uniform_zoom = max(zoom_factor.x, zoom_factor.y, 1.0)
	var target_zoom = Vector2(uniform_zoom, uniform_zoom)
	#applies the smooth transition (0.8 sec)
	var tween = create_tween()
	tween.tween_property(self, "zoom", target_zoom, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func focus_on_player():
	#set to false for the animation duration
	is_following = false
	#sets camera properties
	offset = camera_offset
	#smooth transition
	var tween = create_tween()
	tween.tween_property(self, "position", target.global_position, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "zoom", camera_zoom, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	#follows the player
	tween.tween_callback(func(): 
		is_following = true
	)

#attaches the camera to the player
func attach_to_player(new_player: Node2D):
	#finds the new target
	target = new_player
	#focus on it
	focus_on_player()
