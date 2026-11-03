extends Node

signal start_laser_eye

func _ready():
	start_laser_eye.emit()

func _on_VisibilityNotifier2D_exit_screen():
	#print("Kill")
	self.get_parent().queue_free()
