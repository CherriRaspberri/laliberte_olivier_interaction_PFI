extends Label

#custom colors
const COLOR_A: Color = Color("#f3c100")
const COLOR_B: Color = Color("#b80797")

#flashing speed
@export var flash_interval: float = 0.075

#used for setting a constant interval for the flashing animation
var time_accum: float = 0.0

var is_flashing = false

#starts the flashing animation
func start_flashing():
	is_flashing = true
	#enables process function
	set_process(true)
	#changes the color to color_a
	modulate = COLOR_A

#stops the flashing animation
func stop_flashing():
	is_flashing = false
	#enables process function
	set_process(false)
	#resets the color to color_a
	modulate = COLOR_A

func _process(delta: float) -> void:
	#if label is not flashing, do nothing
	if not is_flashing:
		return
	time_accum += delta
	if time_accum >= flash_interval:
		time_accum = 0.0 
		modulate = COLOR_B if modulate == COLOR_A else COLOR_A
