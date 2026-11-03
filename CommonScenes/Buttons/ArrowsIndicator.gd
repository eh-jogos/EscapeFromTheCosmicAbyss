extends Control

signal right_pressed
signal left_pressed

func show_highlight():
	get_node("ArrowAnimator").play("enabled")


func stop_highlight():
	get_node("ArrowAnimator").play("disabled")

func _on_RightArrow_pressed():
	right_pressed.emit()


func _on_LeftArrow_pressed():
	left_pressed.emit()


func focus_parent():
	get_parent().grab_focus()


func _on_RightArrow_mouse_entered():
	focus_parent()


func _on_LeftArrow_mouse_entered():
	focus_parent()


func _on_ArrowsIndicator_mouse_entered():
	focus_parent()
