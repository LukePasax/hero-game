extends Area2D

# A class to handle the player collision for all hostile elements
func _on_body_entered(body):
	if body is Player:
		body.die()
