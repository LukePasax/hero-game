extends CharacterBody2D

class_name Player

# The acceleration of the character
var acceleration = 50
# The max speed at which the character moves
var speed = 200
# The speed at which the character falls
var gravity = 200
# The maximum velocity with which the character jumps
var jump_impulse = 140
# The minimum velocity with which the character jumps
var min_impulse = 70
# Used when performing unblockable animations
var unblockable = false
var holding = false
# Says if the character is blocking
@export var blocking = false

@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var sword_box = $Sprite2D/Sword/Hitbox
@onready var combo_checker = $ComboChecker
@onready var hit_sound = $HitSound
@onready var jump_sound = $JumpSound

# Called when the node enters the scene tree for the first time.
func _ready():
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
	velocity.y += delta * gravity
	
func apply_friction():
	velocity.x = move_toward(velocity.x, 0, acceleration)

func apply_acceleration(x):
	velocity.x = move_toward(velocity.x, 200 * x, acceleration)

# A function that holds the player in place
func hold():
	animation_player.play("idle")
	holding = true

# A function that plays an unblockable animation
func play_unblockable(animation):
	animation_player.play(animation)
	unblockable = true

# Called when the player hits an enemy with the sword
func _on_sword_body_entered(body):
	if body.is_in_group("Enemy"):
		body.die()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Determine the direction by reading inputs
	var direction = Vector2.ZERO
	direction.x = Input.get_axis("move_left", "move_right")
	
	# If the player is moving apply acceleration, otherwise friction
	if direction.x == 0:
		apply_friction()
	else:
		if direction.x > 0:
			sprite.scale.x = 1
		else:
			sprite.scale.x = -1
		apply_acceleration(direction.x)
	
	apply_gravity(delta)
	
	# Checks if the character is on the floor
	if is_on_floor() and !unblockable:
		# If the player jumps, play the animation and change the y velocity
		if Input.is_action_pressed("jump") and !holding:
			jump_sound.play()
			velocity.y = -jump_impulse
			animation_player.play("jump")
			get_parent().log("jump")
		# If the player presses one of the combo buttons, calls ComboChecker and eventually play the animation
		elif Input.is_action_just_pressed("combo_button_1"):
			var combo = combo_checker.press_key("combo1")
			if (combo != "") and Events.sword:
				get_parent().log(combo)
				play_unblockable(combo)
				holding = false
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
	elif not is_on_floor():
		if Input.is_action_just_released("jump") and velocity.y < -min_impulse:
			velocity.y = -min_impulse
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
