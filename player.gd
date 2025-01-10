extends CharacterBody2D

class_name Player

# CONSTANTS USED BY THE PLAYER
# The acceleration of the character
const ACCELERATION = 70
# The max speed at which the character moves
const SPEED = 220
# The speed at which the character falls
const GRAVITY = 250
# The maximum velocity with which the character jumps
const JUMP_IMPULSE = 170
# The minimum velocity with which the character jumps
const MIN_IMPULSE = 100


# Used when performing unblockable animations
var unblockable = false
# Used when the player is holded in place
var holding = false
# The move vector of the character
var move_vector = Vector2.ZERO
# True if the character is on the ground
var grounded = false
# Says if the character is blocking
@export var blocking = false
 
var move_action = 0
var jump_action = 0
var best_goal_distance = 10000.0
var previous_goal_distance = 10000.0
var current_goal = null
var time_to_goal = 0.0

@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var sword_box = $Sprite2D/Sword/Hitbox
@onready var combo_checker = $ComboChecker
@onready var hit_sound = $HitSound
@onready var jump_sound = $JumpSound
@onready var ai_controller = $AIController2D
@onready var raycast_sensor = $RaycastSensor2D

# Called when the node enters the scene tree for the first time.
func _ready():
	ai_controller.init(self)
	vibrate()
	sword_box.set_deferred("disabled", true)
	load_texture()

# A function that loads the correct texture based on the weapons the player has
func load_texture():
	if Events.sword and Events.shield:
		sprite.texture = load("res://Hero Knight/Sprites/HeroKnight/HeroKnight.png")
	elif Events.sword:
		sprite.texture = load("res://Hero Knight/Sprites/HeroKnight/HeroKnightSword.png")
	elif Events.shield:
		sprite.texture = load("res://Hero Knight/Sprites/HeroKnight/HeroKnightShield.png")
	else:
		sprite.texture = load("res://Hero Knight/Sprites/HeroKnight/HeroKnightNoWeapons.png")

# Called when the player picks up the sword
func pick_up_sword():
	Events.sword = true
	get_parent().log("picked up sword")
	load_texture()

# Called when the player picks up the shield
func pick_up_shield():
	Events.shield = true
	get_parent().log("picked up shield")
	load_texture()

# A function to vibrate the controller
func vibrate():
	Input.start_joy_vibration(0, 1, 1, 0.5)

# Called when the player dies
func die():
	vibrate()
	hit_sound.play()
	get_parent().log("died")
	Events.emit_signal("player_died")
	ai_controller.reward -= 100.0
	ai_controller.reset()

func death_animation():
	animation_player.play("death")

# Called when the player is hit by a projectile
func hit():
	if blocking:
		return false
	else:
		die()
		return true

func apply_gravity(delta):
	velocity.y += delta * GRAVITY
	
func apply_friction():
	velocity.x = move_toward(velocity.x, 0, ACCELERATION)

func apply_acceleration(x):
	velocity.x = move_toward(velocity.x, 200 * x, ACCELERATION)

# A function that holds the player in place
func hold():
	animation_player.play("idle")
	holding = true

func is_holding():
	return holding

func free_from_hold():
	holding = false

# A function that plays an unblockable animation
func play_unblockable(animation):
	animation_player.play(animation)
	unblockable = true

# Called when the player hits an enemy with the sword
func _on_sword_body_entered(body):
	if body.is_in_group("Enemy"):
		body.die()

func _on_sword_area_entered(area):
	if area.is_in_group("Enemy"):
		area.die()

func get_nearest_checkpoint():
	var checkpoints = get_parent().get_active_checkpoint_list()
	var nearest = null
	var min_dist = INF
	
	for checkpoint in checkpoints:
		var distance = global_position.distance_to(to_local(checkpoint.global_position))
		if distance < min_dist:
			min_dist = distance
			nearest = checkpoint
	
	return checkpoints[0]

func get_move_vector() -> Vector2:
	if ai_controller.done:
		return Vector2.ZERO

	if ai_controller.heuristic == "model":
		return Vector2(clamp(move_action, -1.0, 0.5),0)
	
	return Vector2(Input.get_axis("move_left", "move_right"), 0)

func get_jump_action() -> bool:
	if ai_controller.done:
		jump_action = 0
		return false

	if ai_controller.heuristic == "model":
		return jump_action > 0.5

	return Input.is_action_pressed("jump")

func calculate_approach_speed(current_distance: float) -> float:
	var approach_speed = previous_goal_distance - current_distance
	previous_goal_distance = current_distance
	return approach_speed

func update_time_to_goal(delta: float):
	time_to_goal += delta

func reset_time_to_goal():
	time_to_goal = 0.0

func update_reward():
	ai_controller.reward -= 0.05 * time_to_goal # Time Penality
	ai_controller.reward += shaping_reward()

func shaping_reward():
	var s_reward = 0.0
	var next_goal = get_nearest_checkpoint()
	
	# Resets the best goal distance if the current goal has been reached
	if next_goal != current_goal:
		print("New goal detected:", next_goal, "Previous goal:", current_goal)
		current_goal = next_goal
		best_goal_distance = 10000.0
		print(current_goal)
		reset_time_to_goal()
	
	# Calculates the current distance from the goal
	var goal_distance = global_position.distance_to(current_goal.global_position)
	var approach_speed = calculate_approach_speed(goal_distance)
	
	# Rewards if the goal is nearer than before
	if goal_distance < best_goal_distance:
		s_reward += (best_goal_distance - goal_distance) * 0.1
		best_goal_distance = goal_distance
		print(best_goal_distance)
	
	 # Penality for useless movement
	if global_position.distance_to(current_goal.global_position) > best_goal_distance + 5:
		ai_controller.reward -= 0.1
	
	# Rewards based on the approach speed
	s_reward += approach_speed * 0.5
	
	return s_reward 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_time_to_goal(delta)
	move_vector = get_move_vector()
	
	# If the player is moving apply acceleration, otherwise friction
	if move_vector.x == 0:
		apply_friction()
	else:
		if move_vector.x > 0:
			sprite.scale.x = 1
		else:
			sprite.scale.x = -1
		apply_acceleration(move_vector.x)
	
	apply_gravity(delta)
	
	grounded = is_on_floor()
	var jump = get_jump_action()
	
	# Checks if the character is on the floor
	if grounded and !unblockable:
		# If the player jumps, play the animation and change the y velocity
		if jump and !holding:
			jump_sound.play()
			velocity.y = -JUMP_IMPULSE
			animation_player.play("jump")
			get_parent().log("jump")
		# If the player presses one of the combo buttons, calls ComboChecker and eventually play the animation
		elif Input.is_action_just_pressed("combo_button_1"):
			var combo = combo_checker.press_key("combo1")
			if (combo != "") and Events.sword:
				get_parent().log(combo)
				play_unblockable(combo)
		elif Input.is_action_just_pressed("combo_button_2"):
			var combo = combo_checker.press_key("combo2")
			if (combo != "") and Events.shield:
				get_parent().log(combo)
				play_unblockable(combo)
		# If the player is standing still, play the idle animation
		elif velocity.x == 0:
			animation_player.play("idle")
		elif !holding:
			animation_player.play("run")
	elif not grounded:
		if not jump and velocity.y < -MIN_IMPULSE:
			velocity.y = -MIN_IMPULSE
		# Plays the fall animation when in the air and descending
		if velocity.y > 0:
			# The character falls faster
			velocity.y += 5
			animation_player.play("fall")
	# Unlock the animations once the unblockable one is done playing
	elif !animation_player.is_playing() and unblockable:
		unblockable = false
	
	# Move the character
	if !unblockable and !holding:
		move_and_slide()
	
	update_reward()

