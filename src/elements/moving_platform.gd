extends AnimatableBody2D

var start_position

# Called when the node enters the scene tree for the first time.
func _ready():
	start_position = global_position

func _on_player_died():
	global_position = start_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
