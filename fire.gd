extends Node2D

@onready var animation = $AnimationPlayer
@onready var burn = $BurnTime
@onready var delay = $Delay

# Called when the node enters the scene tree for the first time.
func _ready():
	delay.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_burn_time_timeout():
	animation.play("fire_end")
	delay.start()


func _on_delay_timeout():
	animation.play("fire_start")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fire_start":
		animation.play("fire_burn")
		burn.start()
