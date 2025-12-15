extends Area2D

var direction = Vector2(0, 1)
var speed = 600


#moves the laser
func _physics_process(delta: float) -> void:
	global_position += transform.y * speed * delta

#checks when the laser enters in collision
func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	#if enters the player's body, make it explode
	if !self.is_queued_for_deletion() && body.is_in_group("Player"):
		body.call_deferred("explode")
		queue_free()

#when laser is out of screen, remove it from the game
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
