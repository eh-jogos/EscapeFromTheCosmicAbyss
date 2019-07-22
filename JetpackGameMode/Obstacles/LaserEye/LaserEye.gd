extends Node2D

const POSITION_Y = -472

var is_tracking = true
var animator

var raycast_left
var raycast_middle
var raycast_right

var raycasts


func _ready():
	set_pos(Vector2(0, POSITION_Y))
	animator = get_node("AnimationPlayer")
	set_fixed_process(false)
	
	raycast_left = get_node("Root/Raycasts/Left")
	raycast_left = get_node("Root/Raycasts/Middle")
	raycast_left = get_node("Root/Raycasts/Right")
	
	raycasts = get_node("Root/Raycasts").get_children()


func _fixed_process(delta):
	if is_tracking:
		set_global_pos(Vector2(get_parent().player_position.x -480,get_global_pos().y))
	else:
		set_global_pos(get_global_pos())


func start():
	animator.play("enter")
	is_tracking = true
	set_fixed_process(true)


func stop_tracking():
	print("STOP TRACKING! DODGE")
	is_tracking = false