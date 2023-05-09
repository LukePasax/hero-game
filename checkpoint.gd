extends Area2D


func _on_body_entered(body):
	if body is Player:
		Events.emit_signal("hit_checkpoint", position)
		set_deferred("monitoring", false)
