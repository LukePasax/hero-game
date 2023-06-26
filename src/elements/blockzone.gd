extends Area2D


func _on_body_entered(body):
	if body is Player:
		body.hold()
		$CollisionShape2D.set_deferred("disabled", true)
