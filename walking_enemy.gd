extends CharacterBody2D

enum {MOVE, ATTACK, DYING}

var direction =  Vector2.RIGHT
var movement_speed = 25

@onready var ledge_check = $LedgeCast
@onready var hit_check = $HitCast
@onready var sprite = $AnimationPlayer
@onready var hitbox = $Hitbox/CollisionShape2D

var state = MOVE
var facing = false

func _ready():
	hitbox.set_deferred("disabled", true)

# The function that initiates the death of the enemy
func die():
	state = DYING
	hit_check.set_deferred("enabled", false)
	sprite.play("death")
	movement_speed = 0
	hitbox.set_deferred("disabled", true)

# When the death animation finishes playing, delete the enemy
func _on_animation_finished(animation):
	if animation == "death":
		queue_free()
	if animation == "attack":
		var player = get_tree().get_first_node_in_group("Player")
		sprite.play("walk")
		if facing:
			facing = false
			scale.x *= -1
		state = MOVE


func attack_state():
	var player = get_tree().get_first_node_in_group("Player")
	if player != null:
		if ((global_position.x < player.position.x and direction.x < 0) or (global_position.x > player.position.x and direction.x > 0)) and !facing:
			scale.x *= -1
			facing = true
		sprite.play("attack")

func move_state():
	# Cheks if the enemy reached a wall or a ledge
	if is_on_wall() or not ledge_check.is_colliding():
		direction *= -1
		scale.x *= -1
	if hit_check.is_colliding():
		state = ATTACK

	
	velocity = direction * movement_speed
	move_and_slide()


func _physics_process(delta):
	match state:
		MOVE: move_state()
		ATTACK: attack_state()

