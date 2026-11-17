extends Node2D

@export var label: Label = null


func _process(_delta: float) -> void:
	var msg := ""
	var mouse_position: Vector2 = get_local_mouse_position()
	msg += "Mouse Position: %s \n"%[mouse_position]
	
	var screen_size: Vector2 = get_viewport_rect().size
	msg += "Screen Size: %s \n"%[screen_size]
	
	var screen_position: Vector2 = get_global_transform_with_canvas() * mouse_position
	msg += "Screen Position: %s \n"%[screen_position]
	
	var screen_relative_position: Vector2 = screen_position / screen_size
	msg += "Relative Position: %s \n"%[screen_relative_position]
	
	label.text = msg
