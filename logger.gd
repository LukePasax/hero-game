extends Node

var file

# The initial method to call. This opens the log file in write mode
func start_logging():
	file = FileAccess.open("user://log.txt", FileAccess.WRITE)
	file.store_line("started logging")

# The method to call when stopping to log. Otherwise the logged data will be lost
func stop_logging():
	file.store_line("stopped logging")
	file.close()

# Logs the given time and action
func log(time : String, action : String):
	print(time + " " + action)
	file.store_line(time + " " + action)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
