tool
extends Node2D

export(float, 0.0, 1.0, 0.1) var warning_color_1 = 0.0 setget set_warning_color1
export(float, 0.0, 1.0, 0.1) var warning_color_2 = 0.0 setget set_warning_color2
export(float, 0.0, 1.0, 0.1) var warning_color_3 = 0.0 setget set_warning_color3

var warning_animator1
var warning_animator2
var warning_animator3

func _ready():
	warning_animator1 = get_node("FaceOutline/EyeOutline/Eye/ColorChange1/ColorChanger1")
	warning_animator2 = get_node("FaceOutline/EyeOutline/Eye/ColorChange2/ColorChanger2")
	warning_animator3 = get_node("FaceOutline/EyeOutline/Eye/ColorChange3/ColorChanger3")


func set_warning_color1(value):
	warning_color_1 = value
	_set_warning_color(warning_animator1, value)


func set_warning_color2(value):
	warning_color_2 = value
	_set_warning_color(warning_animator2, value)


func set_warning_color3(value):
	warning_color_3 = value
	_set_warning_color(warning_animator3, value)


func _set_warning_color(animator, value):
	if animator == null:
		return
	
	if value == 0:
		animator.play("BASE")
	else:
		animator.set_current_animation("charging")
		animator.seek(warning_animator1.get_current_animation_length()*value, true)
