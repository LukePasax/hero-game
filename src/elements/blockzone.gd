extends Area2D


@onready var player_check = $PlayerCheck
@onready var sprite = $Sprite2D


func die():
	if player_check.is_colliding():
		var body = player_check.get_collider()
		if body is Player and body.is_holding():
			sprite.set_deferred("visible", false)
			body.free_from_hold()
			player_check.set_deferred("enabled", false)


func _process(delta):
	if player_check.is_colliding():
		var body = player_check.get_collider()
		if body is Player and not body.is_holding():
			sprite.set_deferred("visible", true)
			body.hold()
