extends Node
# Represents the sequence of buttons pressed by the player
var keysequence = []
# The max number of key-presses in a combo
var maxcombo = 5
# The list of possible combos
var combos = {"attack1" : ["combo1","combo1"], "block" : ["combo2", "combo2"]}

func press_key(key):
	
	# Put the key in the sequence and check if it completes a combo
	keysequence.push_back(key)
	for curcombo in combos:
		# if it does, clear the sequence and return the finished combo
		if check_combo(keysequence, combos[curcombo]):
			print(curcombo)
			keysequence.clear()
			return curcombo
	
	# If the number of keys is higher than the max, forget the oldes key pressed
	if keysequence.size() > maxcombo:
		keysequence.pop_front()
	$ComboTimer.start()
	return ""

func check_combo(s, t):
	# Fail if not enough keys pressed
	if s.size() < t.size():
		return false
	
	# Slice the last X key presses so both arrays start at same point
	var c = s.duplicate()
	c.reverse()
	c.resize(t.size())
	c.reverse()
	
	# Fail if any pressed key sequence don't match the combo
	for i in range(t.size()):
		if c[i] != t[i]:
			return false
	
	# All keys matches, execute combo
	return true

func _on_combo_timer_timeout():
	keysequence.clear()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

