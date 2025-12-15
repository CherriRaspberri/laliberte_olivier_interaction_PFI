extends Node2D

func emit_sound(type):
	match type:
		"big":
			$score_sound.play()
		"small":
			$score_sound_small.play()

#erases the score after the timer is done
func _on_timer_timeout() -> void:
	queue_free()
