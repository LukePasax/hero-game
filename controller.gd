extends AIController2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	n_steps += 1
	if n_steps >= reset_after:
		done = true
		needs_reset = true
	
	if needs_reset:
		_player.die()

func get_obs():
	var obs: Array = []
	var goal = _player.current_goal
	
	# Get the goal distance realtive to the player
	var goal_relative_distance: Vector2 = _player.to_local(goal.global_position)
	var normalized_goal_relative_distance = goal_relative_distance.limit_length(100) / 100
	obs.append(normalized_goal_relative_distance.x)
	obs.append(normalized_goal_relative_distance.y)
	obs.append(_player.grounded)
	obs.append_array(_player.raycast_sensor.get_observation())

	return {
		"obs": obs,
	}

func get_action():
	return [_player.move_vector, _player.jump_action]

func set_action(action):
	if action:
		_player.move_action = action["move"][0]
		_player.jump_action = action["jump"][0]
	else:
		_player.move_action = Vector2(Input.get_axis("move_left", "move_right"), 0)
		_player.jump_action = Input.is_action_pressed("jump")

func get_action_space() -> Dictionary:
	var action_space = {
		"jump": {"size": 1, "action_type": "continuous"},
		"move": {"size": 1, "action_type": "continuous"}
	}
	print("get_action_space() called, returning: ", action_space)
	return action_space


func get_reward():
	return reward
