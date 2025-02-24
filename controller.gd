extends AIController2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
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
	var goal_relative_distance: Vector2 = _player.to_local(goal.global_position).limit_length(100) / 100
	obs.append(goal_relative_distance.x)
	obs.append(goal_relative_distance.y)
	
	
	var closest_checkpoint = _player.get_nearest_checkpoint()
	if closest_checkpoint != null:
		var checkpoint_relative_distance: Vector2 = _player.to_local(closest_checkpoint.global_position).limit_length(100) / 100
		obs.append(checkpoint_relative_distance.x)
		obs.append(checkpoint_relative_distance.y)
	else:
		obs.append(0.0)
		obs.append(0.0)
	
	obs.append(_player.velocity.x / _player.SPEED)
	obs.append(_player.velocity.y / 300)
	obs.append(_player.jump_time)
	obs.append(1.0 if _player.is_on_floor() else 0.0)
	obs.append_array(_player.raycast_sensor.get_observation())

	return {
		"obs": obs,
	}

func get_action():
	return [_player.move_vector, _player.jump_action]

func set_action(action):
	if action:
		_player.move_action = action["move"][0]
		_player.jump_action = action["jump"]
	else:
		_player.move_action = Vector2(Input.get_axis("move_left", "move_right"), 0)
		_player.jump_action = Input.is_action_pressed("jump")

func get_action_space() -> Dictionary:
	var action_space = {
		"jump": {"size": 1, "action_type": "discrete"},
		"move": {"size": 1, "action_type": "continuous"}
	}
	print("get_action_space() called, returning: ", action_space)
	return action_space


func get_reward():
	return reward
