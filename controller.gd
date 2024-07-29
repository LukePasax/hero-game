extends AIController2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	n_steps += 1

func get_obs():
	var goal = _player.get_nearest_checkpoint()
	
	var goal_distance = _player.position.distance_to(goal)
	var goal_position = goal.global_position
	
	var goal_vector = _player.to_local(goal_position).normalized()
	
	goal_distance = clamp(goal_distance, 0.0, 20.0)
	var obs = []
	obs.append_array(
		[
			_player.move_vector.x / _player.SPEED,
			_player.move_vector.y
		]
	)
	obs.append_array([goal_distance / 20.0, goal_vector.x, goal_vector.y])
	obs.append(_player.grounded)

	return {
		"obs": obs,
	}

func set_action(action):
	_player.move_action = action["move"][0]
	_player.jump_action = action["jump"][0] > 0

func get_action_space():
	return {
		"jump": {"size": 1, "action_type": "continuous"},
		"move": {"size": 1, "action_type": "continuous"},
	}
