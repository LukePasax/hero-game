extends AIController2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	n_steps += 1

func get_obs():
	var goal_distance = 0.0
	var goal_position = Vector2.ZERO
