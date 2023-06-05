extends Area2D



func _on_body_entered(body):
	if body is Player:
		body.pick_up_shield()
		Events.emit_signal("pickup")
		queue_free()
