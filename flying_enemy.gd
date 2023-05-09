extends Path2D

enum { MOVE, ATTACK }

@onready var animation = $AnimationPlayer
@onready var sprite = $PathFollow2D/Enemy/AnimatedSprite2D
@onready var timer = $AttackTimer
@onready var enemy = $PathFollow2D/Enemy
@onready var player = get_tree().get_first_node_in_group("Player")

var state = MOVE

func _on_attack_timer_timeout():
	state = ATTACK

func _on_animated_sprite_2d_animation_finished():
	if sprite.animation == "attack":
		state = MOVE
		timer.start()

func move_state():
	animation.play()
	sprite.play("fly")

func attack_state():
	animation.pause()
	sprite.play("attack")
	

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	player = get_tree().get_first_node_in_group("Player")
	if player != null:
		if player.position.x > enemy.global_position.x:
			enemy.scale.x = 1
		elif player.position.x < enemy.global_position.x:
			enemy.scale.x = -1
		match state:
			MOVE: move_state()
			ATTACK: attack_state()

