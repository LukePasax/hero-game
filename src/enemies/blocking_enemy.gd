extends CharacterBody2D

enum {IDLE, ATTACK, DEATH}

@onready var sprite = $AnimationPlayer
@onready var player_check = $PlayerCheck

var state = IDLE

func _ready():
	set_deferred("visible", true)


# The function that initiates the death of the enemy
func die():
	state = DEATH
	sprite.play("death")
	get_parent().log("Enemy Slain")

func attack_finished():
	state = IDLE

func attack_state():
	sprite.play("attack")

func idle_state():
	sprite.play("idle")
	if player_check.is_colliding():
		state = ATTACK
		player_check.set_deferred("enabled", false)


func _physics_process(delta):
	match state:
		IDLE: idle_state()
		ATTACK: attack_state()
