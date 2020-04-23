extends Node2D

var animator

func _ready():
	animator = get_node("AnimationPlayer")



func _on_Exit_pressed():
	close()


func _on_Reset_pressed():
	pass # replace with function body


func close():
	if get_tree().get_current_scene() == self:
		hide()
	else:
		ScreenManager.black_transition_from_above()