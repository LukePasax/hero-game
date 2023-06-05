extends Area2D

@export_enum("Sword", "Shield", "Generate") var level: String

@onready var dest_sprite = $Destination
@onready var player_check = $RayCast2D
var dest

func load_sword():
	dest_sprite.texture = load("res://resources/Levels/sword.png")
	dest = "res://levels/level_sword.tscn"

func load_shield():
	dest_sprite.texture = load("res://resources/Levels/shield.png")
	dest = "res://levels/level_shield.tscn"
	
func load_final():
	dest_sprite.texture = load("res://resources/Levels/skull.png")
	dest = "res://levels/level_final.tscn"

func setup():
	print("ah")
	if level == "Sword":
		load_sword()
	if level == "Shield":
		load_shield()
	if level == "Generate":
		if Events.shield and Events.sword:
			load_final()
		elif Events.sword:
			load_shield()
		elif Events.shield:
			load_sword()
		else:
			pass

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("pickup", setup)
	setup()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player_check.is_colliding() and Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file(dest)
