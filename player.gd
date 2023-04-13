extends CharacterBody2D

# The speed at which the character moves
@export var speed = 200
# The speed at which the character falls
@export var gravity = 200
# The impulse with which the character jumps
@export var jump_impulse = 80

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
	
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y -= jump_impulse
			$AnimatedSprite2D.play("jump")
		elif velocity.x == 0:
			$AnimatedSprite2D.play("idle")
		else:
			$AnimatedSprite2D.play("run")
	else:
		if velocity.y > 0:
			$AnimatedSprite2D.play("fall")
	
	# Move the character
	move_and_slide()
