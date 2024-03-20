extends Node2D

func start_game():
	get_tree().change_scene_to_file("res://levels/level_1.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("interact"):
		start_game()
