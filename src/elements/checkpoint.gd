extends Area2D

func _ready():
	Events.connect("player_died", _on_player_died)

func _on_player_died():
	set_deferred("monitoring", true)

func _on_body_entered(body):
	if body is Player:
		Events.emit_signal("hit_checkpoint", position)
		set_deferred("monitoring", false)
