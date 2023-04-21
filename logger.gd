extends Node

var logs = ""
var file_name

# The method to call when stopping to log. It saves the logged data to a file with the given name
func stop_logging(name):
	var file = FileAccess.open("user://" + name + ".txt", FileAccess.WRITE)
	file.store_string(logs)
	file.close()

# Logs the given time and action
func log(time : String, action : String):
	logs += time + " " + action + "\n"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
