extends Node2D

@onready var player = $Player
@onready var respawn_timer = $RespawnTimer
@onready var ambient_music = $AmbientMusic
@onready var boss_music = $BossMusic	
@onready var animation = $AnimationPlayer
var player_spawn = Vector2.ZERO
var recording = false

func _on_player_died():
	player.position = player_spawn
	player.death_animation()

func _on_hit_checkpoint(checkpoint_position):
	player_spawn = checkpoint_position

func _on_trigger_boss():
	ambient_music.stop()
	boss_music.play()

func _on_boss_died():
	boss_music.stop()
	ambient_music.play()
	animation.play("EndGame")

func to_endscreen():
	get_tree().change_scene_to_file("res://src/cutscenes/end_screen.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	player_spawn = player.position
	Events.connect("player_died", _on_player_died)
	Events.connect("hit_checkpoint", _on_hit_checkpoint)
	Events.connect("trigger_boss", _on_trigger_boss)
	Events.connect("boss_died", _on_boss_died)

# A function that logs an action and the time it was performed
func log(action):
	print(action)
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
