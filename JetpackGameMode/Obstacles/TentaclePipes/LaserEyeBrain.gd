extends Node

signal start_laser_eye

func _on_VisibilityNotifier2D_exit_screen():
	#print("Kill")
	self.get_parent().queue_free()



func _on_VisibilityNotifier2D_enter_screen():
	emit_signal("start_laser_eye")
	print("LASER EYE FIRE AWAY")
