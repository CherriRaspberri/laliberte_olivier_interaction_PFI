extends Node2D

#imports the menu node
@onready var pause_menu = $CanvasLayer/pause_menu
#fetches the camera
@export var camera_path: NodePath = NodePath("")
var camera: Node2D
#imports the player node
var player_scene = preload("res://scenes/player.tscn")

#level properties
@export var level_name: String
@export var level_nb: int 
var paused = false
var is_game_over = false
var can_restart = true
#score properties
var score = 0
var score_threshold = 1000
var level_completion_threshold: int
var level_completed = false
#time properties
var time
var seconds: int

#enemy properties
var enemy_list = null

func _ready() -> void:
	#fetches camera
	camera = get_node_or_null(camera_path)
	
	#sets level completion threshold
	if level_nb == 1:
		level_completion_threshold = 3000
	elif level_nb == 2:
		#fetches enemy in group
		enemy_list = get_tree().get_nodes_in_group("Enemy")
	elif level_nb == 3:
		#almost infinite; score does not matter, since it's a timed level
		level_completion_threshold = 100000
	
	#sets the wall shaders to move correctly
	$game_wall_left/Sprite2D.material.set_shader_parameter("direction", Vector2(-1.0, 0.0))
	$game_wall_right/Sprite2D.material.set_shader_parameter("direction", Vector2(1.0, 0.0))
	
	#sets the player's hitbox as active
	$Player.disable_hitbox(false)
	
	#shows level message - checks what level the player is in; 
	#if on timed level, start timer after level message is done
	$level_start_sound.play()
	if level_nb < 3:
		await show_message(level_name, 1)
	else:
		await show_message(level_name, 1)
		$survival_timer.start()
		$difficulty_timer.start()

func _process(delta: float) -> void:
	#checks every frame if the "pause" key has been pressed
	if Input.is_action_just_pressed("pause"):
		#checks if the camera is still there; if it isn't, don't show the menu
		camera = get_node_or_null(camera_path)
		if camera != null:
			show_pause_menu()
	
	#updates the score variable every frame
	score = int($CanvasLayer/GUI/MarginContainer/HBoxContainer/score.text)
	#if it is not timed level, winning conditions are with points; 
	#checks win conditions accordingly
	if level_nb == 1:
		#checks anytime if the score has passed its threshold; 
		#if it has, augment difficulty
		if score >= score_threshold and score < level_completion_threshold:
			augment_difficulty()
		
		#if score went above threshold, complete level
		if score >= level_completion_threshold and not level_completed:
			complete_level()
	
	if level_nb == 2: 
		#fetches enemy in group
		enemy_list = get_tree().get_nodes_in_group("Enemy")
		#if enemy is not there anymore, complete level
		if enemy_list.is_empty() and not level_completed:
			print("Level complete")
			complete_level()
	
	#updates the timer
	if level_nb == 3:
		#fetches how much time is left
		time = $survival_timer.time_left
		#displays the time
		seconds = int(time) % 60
		$CanvasLayer/GUI/timer_label.text = "%02d" % [seconds]

#if the game is not paused, pause it, and vice-versa
func show_pause_menu():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		pause_menu.show()
		Engine.time_scale = 0
	paused = !paused

#shows a flashing message when called; requires message and duration
func show_message(message: String, duration: int):
	#shows game message
	$CanvasLayer/GUI/message_label.visible = true
	$CanvasLayer/GUI/message_label.text = message
	#makes the message flash
	$CanvasLayer/GUI/message_label.start_flashing()
	#waits for the required amount of time
	await get_tree().create_timer(duration).timeout
	#stops showing the message
	$CanvasLayer/GUI/message_label.stop_flashing()
	$CanvasLayer/GUI/message_label.visible = false

#augments the difficulty
func augment_difficulty():
	#augments the difficulty
	$Comet_spawner.augment_difficulty()
	#checks if it is not a timed level
	if level_nb < 3:
		#augments the threshold
		score_threshold += 1000
	#shows difficulty upgrade message for 1 second
	$difficulty_sound.play()
	show_message("More comets incoming", 1)

#stops the game and switches it to a game over state 
func _on_player_player_died() -> void:
	#shakes the screen
	camera.random_strength = 30
	camera.apply_shake()
	#stops the game music
	$music.stop()
	#stops new comets from spawning
	if level_nb != 2:
		$Comet_spawner/spawn_timer.stop()
	#hides the survival timer and stops the difficulty timer (if present)
	if level_nb == 3:
		$CanvasLayer/GUI/timer_label.visible = false
		$difficulty_timer.stop()
	#starts the game over timer
	$game_over_timer.start()

#shows game over screen
func _on_game_over_timer_timeout() -> void:
	#disables the player to restart
	can_restart = false
	#shows game over screen
	$game_over_label.visible = true
	$game_over_label/restart_label.visible = false
	#plays game over sound
	$death_sound.play()
	#game is over
	is_game_over = true
	#waits for the sound to finish
	await $death_sound.finished
	#shows restart label
	$game_over_label/restart_label.visible = true
	#enables the player to restart
	can_restart = true

#when this timer ends, augments difficulty
func _on_difficulty_timer_timeout() -> void:
	augment_difficulty()

#when this timer ends, complte the level
func _on_survival_timer_timeout() -> void:
	#stops the difficulty timer 
	#(so it dos not trigger at the same time as the level timer)
	$difficulty_timer.stop()
	complete_level()

#checks if restart key has been pressed
#removes confusion over which event is used with the space key
func _unhandled_input(event: InputEvent) -> void:
	if can_restart and is_game_over and event.is_action_released("restart"):
		restart_game()

#restarts the game
func restart_game():
	is_game_over = false
	#hides the game over screen
	$game_over_label.visible = false
	#restarts the game music
	$music.play(0)
	
	#respawns the player
	var player = player_scene.instantiate()
	player.position = Vector2(640, 655)
	player.player_died.connect(_on_player_player_died)
	add_child(player)
	player.add_to_group("Player")
	camera.attach_to_player(player)
	#sets the player's hitbox as active
	$Player.disable_hitbox(false)
	
	#respawns comets
	if level_nb != 2:
		$Comet_spawner.respawn_comets()
		#resets score to 0
		$CanvasLayer/GUI/MarginContainer/HBoxContainer/score.text = "0"
		#resets difficulty
		score_threshold = 1000
		$Comet_spawner.reset_difficulty()
	#resets enemy
	if level_nb == 2:
		$enemy_path/PathFollow2D/Enemy.reset_health()
	#resets timer (if present)
	if level_nb == 3:
		$survival_timer.stop()
		$survival_timer.wait_time = 60
		$survival_timer.start()
		#shows timer label
		$CanvasLayer/GUI/timer_label.visible = true
		#restarts the difficulty timer
		$difficulty_timer.wait_time = 15
		$difficulty_timer.start()
		
	#shows level message
	$level_start_sound.play()
	await show_message(level_name, 1)

#completes the level and switches to other levels accordingly
func complete_level():
	level_completed = true
	#stops the comets from destroying the player
	$Player.disable_hitbox(true)
	#stops new comets from spawning
	if level_nb != 2:
		$Comet_spawner/spawn_timer.stop()
	#stops the music
	$music.stop() 
	#emits level complete sound
	$level_complete_sound.play()
	#shows level complete message
	await show_message("You cleared the way", 3)
	#changes scene to correct level
	if level_nb == 1:
		get_tree().change_scene_to_file("res://scenes/game_lvl_2.tscn") 
	elif level_nb == 2:
		get_tree().change_scene_to_file("res://scenes/game_lvl_3.tscn")
	elif level_nb == 3:
		#unlocks the ability to restart
		is_game_over = true
		#emits game win sound
		$game_complete_sound.play()
		#shows win message
		await show_message("You win", 5)
		get_tree().change_scene_to_file("res://scenes/game.tscn")
