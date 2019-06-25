extends Node2D

const POSITION_Y = -472

var is_tracking = true
var animator

func _ready():
	set_pos(Vector2(0, POSITION_Y))
	animator = get_node("AnimationPlayer")
	set_fixed_process(false)

func _fixed_process(delta):
	if is_tracking:
		set_global_pos(Vector2(get_parent().player_position.x -480,get_global_pos().y))
	else:
		set_global_pos(get_global_pos())


func start():
	animator.play("enter")
	is_tracking = true
	set_fixed_process(is_tracking)


func stop_tracking():
	print("STOP TRACKING! DODGE")
	is_tracking = false
	set_fixed_process(false)