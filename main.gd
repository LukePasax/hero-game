extends Node2D

@onready var player = $Player
@onready var respawn_timer = $RespawnTimer
var player_spawn = Vector2.ZERO
var recording = false

func _on_player_died():
	player.position = player_spawn

func _on_hit_checkpoint(checkpoint_position):
	player_spawn = checkpoint_position

# Called when the node enters the scene tree for the first time.
func _ready():
	player_spawn = player.position
	Events.connect("player_died", _on_player_died)
	Events.connect("hit_checkpoint", _on_hit_checkpoint)


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
