@tool
extends CanvasLayer


@export var play_laser_eye: bool = false:
	set(value):
		if value:
			_play_laser_eye()
			await get_tree().create_timer(0.5).timeout
			value = false
@export var laser_eye: Node2D

func _play_laser_eye() -> void:
	laser_eye.start()
	pass
