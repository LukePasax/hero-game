extends CharacterBody2D

# The speed at which the character moves
@export var speed = 200
# The speed at which the character falls
@export var gravity = 200
# The impulse with which the character jumps
@export var jump_impulse = 80
# Used when performing unblockable animations
var unblockable = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Create the direction vector
	var direction = Vector2.ZERO
	# Determine the direction by reading inputs
	if Input.is_action_pressed("move_right"):
		direction.x += 1
		$AnimatedSprite2D.flip_h = false
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
		$AnimatedSprite2D.flip_h = true
	
	# Normalize the direction
	if direction.length() > 0:
		direction = direction.normalized()
	
	# Ground velocity
	velocity.x = direction.x * speed
	
	# Apply gravity
	velocity.y += delta * gravity
	# Checks if the character is on the floor
	if is_on_floor() and !unblockable:
		# If the player jumps, play the animation and change the y velocity
		if Input.is_action_just_pressed("jump"):
			velocity.y -= jump_impulse
			$AnimatedSprite2D.play("jump")
		# If the player presses one of the combo buttons, calls ComboChecker and eventually play the animation
		elif Input.is_action_just_pressed("combo_button_1"):
			var combo = $ComboChecker.press_key("combo1")
			if (combo != ""):
				$AnimatedSprite2D.play(combo)
				unblockable = true
		elif Input.is_action_just_pressed("combo_button_2"):
			var combo = $ComboChecker.press_key("combo2")
			if (combo != ""):
				$AnimatedSprite2D.play(combo)
				unblockable = true
		# If the player is standing still, play the idle animation
		elif velocity.x == 0:
			$AnimatedSprite2D.play("idle") 
		# If the player is moving play the run animation
		else:
			$AnimatedSprite2D.play("run")
	elif not is_on_floor():
		# Plays the fall animation when in the air and descending
		if velocity.y > 0:
			$AnimatedSprite2D.play("fall")
	# Unlock the animations once the unblockable one is done playing
	elif !$AnimatedSprite2D.is_playing() and unblockable:
		unblockable = false
	
	# Move the character
	if !unblockable:
		move_and_slide()
