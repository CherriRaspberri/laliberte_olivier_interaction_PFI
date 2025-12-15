extends Area2D

#creates the direction for the laser (0 = no x movement, -1 = y movement upwards)
var direction = Vector2(0, -1)
var speed = 1000

#moves the laser
func _process(delta: float) -> void:
	self.position += direction * speed * delta

#when laser is out of screen, remove it from the game
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

#checks when the laser enters in collision
func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	#if the laser is not already queued for deletion, delete it
	#this prevents a glitch when 2 lasers are supposed to get deleted at the same time
	if (!self.is_queued_for_deletion() && body.is_in_group("comets")):
		#Calls the function in the comet's script;
		#Call deferred will wait until the queue is free to activate
		body.call_deferred("explode")
		queue_free()
	if (!self.is_queued_for_deletion() && body.is_in_group("Enemy")):
		#Calls the function in the enemy's script;
		#Call deferred will wait until the queue is free to activate
		body.call_deferred("update_health")
		queue_free()
