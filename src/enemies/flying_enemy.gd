extends Path2D

enum { MOVE, ATTACK, DYING }

@onready var animation = $AnimationPlayer
@onready var sprite = $PathFollow2D/Enemy/AnimatedSprite2D
@onready var timer = $AttackTimer
@onready var enemy = $PathFollow2D/Enemy
@onready var player = get_tree().get_first_node_in_group("Player")

var fireball = preload("res://src/enemies/fireball.tscn")

var state = MOVE


# The enemy attacks every 2 seconds should the player be within 300 pixels of the enemy.
func _on_attack_timer_timeout():
	player = get_tree().get_first_node_in_group("Player")
	if player != null and player.position.x > enemy.global_position.x-300 and player.position.x < enemy.global_position.x+300:
		state = ATTACK
	else:
		timer.start()
	

# The enemy attacks the player with a fireball.
func _on_animated_sprite_2d_animation_finished():
	if sprite.animation == "attack":
		var fb = fireball.instantiate()
		fb.set_enemy(enemy)
		fb.global_position = enemy.global_position
		get_tree().get_root().add_child(fb)
		state = MOVE
		timer.start()
	elif sprite.animation == "death":
		queue_free()

func move_state():
	animation.play()
	sprite.play("fly")

func attack_state():
	animation.pause()
	sprite.play("attack")

func dying_state():
	animation.pause()
	get_parent().log("Enemy slain")
	sprite.play("death")

func _on_hitbox_area_entered(area):
	if area is Fireball and area.seeking:
		area.queue_free()
		state = DYING

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
			DYING: dying_state()

