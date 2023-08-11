extends Area2D

class_name Fireball

var player_pos
var speed = 200
var direction
var shooter
var seeking = false


# Called to check if the fireball hit the player, the boss, an enemy or a wall
func _on_body_entered(body):
	if body is Player:
		var died = body.hit()
		if died:
			queue_free()
		else:
			get_parent().log("Player countered fireball")
			direction = (shooter.global_position - global_position).normalized()
			seeking = true
	elif body is Boss:
		body.die()
		queue_free()
	else:
		queue_free()

# Called to set the enemy that shot the fireball so that it can seek it
func set_enemy(enemy):
	shooter = enemy

# Called when the node enters the scene tree for the first time.
func _ready():
	player_pos = get_tree().get_first_node_in_group("Player").position
	direction = (player_pos - global_position).normalized()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if seeking:
		direction = (shooter.global_position - global_position).normalized()
	translate(direction*speed*delta)
