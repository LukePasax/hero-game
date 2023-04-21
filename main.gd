extends Node2D

var recording = false


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

func log(action):
	if recording:
		$Logger.log($WebSocketClient.get_recording_time(), action)

# A function that handles a variety of inputs
func _unhandled_input(event):
	# Connects to the obs websocket
	if event.is_action_pressed("connect_to_obs"):
		$WebSocketClient.connect_to_obs()
	# Stops recording and saves the log
	if event.is_action_pressed("record") and recording:
		var name = $WebSocketClient.stop_recording()
		name = name.get_file()
		var file_extension = name.get_extension()
		name = name.left(name.length() - file_extension.length() - 1)
		$Logger.stop_logging(name)
		recording = false
	# Starts recording
	if event.is_action_pressed("record") and !recording:
		$WebSocketClient.start_recording()
		recording = true
