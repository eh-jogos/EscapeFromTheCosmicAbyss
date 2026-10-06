extends "res://JetpackGameMode/BG/BG_LooperH.gd"

func _process(_delta):
	#print("Global Pos: %s | Pos: %s"%[global_position, position])
	if end_point.global_position.x < 0: 
		#print("Move Sprite!")
		if get_owner().current_level == 5:
			frame = 5
		else:
			frame = get_random_frame()
		var new_pos = Vector2(position.x + (2*2020), position.y)
		position = new_pos


func get_random_frame() -> int:
	var value = randi() % sprite_frames.get_frame_count(animation)
	return value
