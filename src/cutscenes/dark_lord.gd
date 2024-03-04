extends Sprite2D

@onready var animation = $AnimationPlayer

func play_attack() :
	animation.play("attack")

func play_idle() :
	animation.play("idle")

func play_walk() :
	animation.play("walk")
