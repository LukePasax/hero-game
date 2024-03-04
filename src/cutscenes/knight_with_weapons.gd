extends Sprite2D

@onready var animation = $AnimationPlayer

func play_death() :
	animation.play("death")

func play_idle() :
	animation.play("idle")

func play_walk() :
	animation.play("walk")
