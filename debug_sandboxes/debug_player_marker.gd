extends Marker2D

@export_range(100.0, 10000.0, 25.0,"or_greater") var max_speed: float = 500.0


func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_right"):
		position.x += max_speed * delta
	elif Input.is_action_pressed("ui_left"):
		position.x -= max_speed * delta
	pass
