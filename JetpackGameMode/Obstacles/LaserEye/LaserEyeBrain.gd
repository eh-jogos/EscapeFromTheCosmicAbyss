extends Node

signal start_laser_eye

func _ready():
	emit_signal("start_laser_eye")

func _on_VisibilityNotifier2D_exit_screen():
	#print("Kill")
	self.get_parent().queue_free()
