extends Node

var socket = WebSocketPeer.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect the socket to the obs websocket url
	socket.connect_to_url("ws://192.168.1.15:4454")
	print("connecting")
	# Await for obs request for identification
	while socket.get_available_packet_count() == 0:
		socket.poll()
	print("connected")
	var message = socket.get_packet().get_string_from_ascii()
	# Prepare and send the identification message
	message = {
  "op": 1,
  "d": {
	"rpcVersion": 1,
	"authentication": "",
	"eventSubscriptions": 33
  }
}
	print("identifying")
	socket.send_text(JSON.stringify(message))
	while socket.get_available_packet_count() == 0 && socket.get_ready_state() != WebSocketPeer.STATE_CLOSED:
		socket.poll()
	message = socket.get_packet().get_string_from_ascii()
	

# A method that stops the recording on obs
func stop_recording():
	print("stop recording")
	# Send to obs the message to stop recording
	var message = {
  "op": 6,
  "d": {
	"requestType": "StopRecord",
	"requestId": "f819dcf0-89cc-11eb-8f0e-382c4ac93b9c"
  }
}
	socket.send_text(JSON.stringify(message))
	while socket.get_available_packet_count() == 0 && socket.get_ready_state() != WebSocketPeer.STATE_CLOSED:
		socket.poll()
	message = socket.get_packet().get_string_from_ascii()
	print(message)

# A method that starts the recording on obs
func start_recording():
	print("start recording")
	var message = {
  "op": 6,
  "d": {
	"requestType": "StartRecord",
	"requestId": "f819dcf0-89cc-11eb-8f0e-382c4ac93b9c"
  }
}
	socket.send_text(JSON.stringify(message))
	while socket.get_available_packet_count() == 0 && socket.get_ready_state() != WebSocketPeer.STATE_CLOSED:
		socket.poll()
	message = socket.get_packet().get_string_from_ascii()
	print(message)

# A method to get the time of recording
func get_recording_time():
	var message = {
  "op": 6,
  "d": {
	"requestType": "GetRecordStatus",
	"requestId": "f819dcf0-89cc-11eb-8f0e-382c4ac93b9c"
  }
}
	socket.send_text(JSON.stringify(message))
	while socket.get_available_packet_count() == 0 && socket.get_ready_state() != WebSocketPeer.STATE_CLOSED:
		socket.poll()
	message = socket.get_packet().get_string_from_ascii()
	return JSON.parse_string(message)["d"]["responseData"]["outputTimecode"]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	socket.poll()
	
