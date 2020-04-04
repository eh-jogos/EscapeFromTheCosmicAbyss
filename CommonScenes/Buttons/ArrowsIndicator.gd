extends Control

func show_highlight():
	get_node("ArrowAnimator").play("enabled")


func stop_highlight():
	get_node("ArrowAnimator").play("disabled")