extends Control

signal right_pressed
signal left_pressed

func show_highlight():
	get_node("ArrowAnimator").play("enabled")


func stop_highlight():
	get_node("ArrowAnimator").play("disabled")

func _on_RightArrow_pressed():
	emit_signal("right_pressed")


func _on_LeftArrow_pressed():
	emit_signal("left_pressed")


func focus_parent():
	get_parent().grab_focus()


func _on_RightArrow_mouse_entered():
	focus_parent()


func _on_LeftArrow_mouse_entered():
	focus_parent()


func _on_ArrowsIndicator_mouse_entered():
	focus_parent()

