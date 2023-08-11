extends Node2D

@onready var label = $RichTextLabel
@onready var check = $PlayerCheck
@onready var saved = $SavedAlly
@onready var hanging = $HangingAlly


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if check.is_colliding() and Input.is_action_just_pressed("ui_accept"):
		label.text = "Thank You!"
		saved.set_deferred("visible", true)
		hanging.set_deferred("visible", false)
		

func _on_area_2d_body_entered(body):
	if body is Player:
		label.set_deferred("visible", true)
