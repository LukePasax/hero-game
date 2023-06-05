extends Area2D

@onready var hitbox = $CollisionShape2D 


# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("player_died", reset)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func reset():
	hitbox.set_deferred("disabled", false)

func _on_body_entered(body):
	if body is Player:
		Events.emit_signal("trigger_boss")
		hitbox.set_deferred("disabled", true)
