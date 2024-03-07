extends CharacterBody2D

class_name Boss

enum states {IDLE, MOVE, ATTACK, CAST, HURT, DEATH}

@onready var hitbox = $Sword/Hitbox
@onready var hurtbox = $Hurtbox
@onready var animation = $AnimationPlayer
@onready var health_bar = $HealthBar
@onready var attack_timer = $AttackTimer
@onready var cast_timer = $CastTimer
@onready var cast_spawn = $CastSpawn
@onready var hit_pivot = $HitPivot
@onready var smoke = $Smoke
var fireball = preload("res://src/enemies/fireball.tscn")

var movement_speed = 25
var direction
# The health points of the boss
var hp
# The initial spawn point
var spawn_point
var cast_point

@export var state: states = states.IDLE

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Boss ready")
	smoke.set_deferred("visible", false)
	spawn_point = global_position
	cast_point = get_parent().get_node("CastPoint").global_position
	Events.connect("trigger_boss", start)
	Events.connect("player_died", setup)
	setup()

# Called to reset the boss
func setup():
	attack_timer.stop()
	cast_timer.stop()
	hitbox.set_deferred("disabled", true)
	global_position = spawn_point
	hp = 4
	health_bar.value = hp
	direction = Vector2.LEFT
	state = states.IDLE

# Activate the boss
func start():
	state = states.MOVE
	attack_timer.start()

func _on_sword_body_entered(body):
	if body is Player:
		body.die()

func _on_attack_timer_timeout():
	state = states.ATTACK

func _on_cast_timer_timeout():
	state = states.CAST

# Called to shoot a fireball at the player
func cast():
	var fb = fireball.instantiate()
	fb.set_enemy(hit_pivot)
	fb.set_spawn(cast_spawn)
	get_parent().add_child(fb)


# Called when the boss is hit. if the boss is hit an hp amount of times, it dies
func die():
	hp -= 1
	health_bar.value = hp
	if hp == 0:
		attack_timer.stop()
		cast_timer.stop()
		state = states.DEATH
		animation.play("death")
		get_parent().log("Boss died")
		Events.emit_signal("boss_died")
	else:
		attack_timer.stop()
		cast_timer.stop()
		state = states.HURT
		animation.play("hurt")

func invert_dir():
	direction.x *= -1

# Called to change the boss's phase
func change_phase():
	if hp % 2 == 0:
		attack_timer.start()
		animation.play("teleport_to_move")
		global_position = spawn_point
	else:
		cast_timer.start()
		animation.play("teleport_to_cast")
		global_position = cast_point

func idle_state():
	animation.play("idle")

func move_state():
	if direction == Vector2.LEFT:
		animation.play("walk")
	else:
		animation.play_backwards("walk")
	velocity = direction * movement_speed
	move_and_slide()

func attack_state():
	var player = get_tree().get_first_node_in_group("Player")
	if player != null:
		animation.play("attack")

func cast_state():
	var player = get_tree().get_first_node_in_group("Player")
	if player != null:
		animation.play("cast")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match state:
		states.IDLE: idle_state()
		states.MOVE: move_state()
		states.ATTACK: attack_state()
		states.CAST: cast_state()
