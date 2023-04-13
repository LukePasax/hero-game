extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var target = $Player.position
	var camera_pos = $PlayerCamera.position
	var new_pos = camera_pos.lerp(target, 1)
	$PlayerCamera.position = new_pos
	$PlayerCamera.zoom = Vector2(3, 3)
