extends Sprite2D

@onready var animation_player = $AnimationPlayer

func open_door():
	animation_player.play("open")
