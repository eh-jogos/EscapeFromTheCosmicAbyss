extends "res://JetpackGameMode/BG/BG_LooperH.gd"

func _process(delta):
	#print("Global Pos: %s | Pos: %s"%[self.global_position, self.position])
	if end_point.global_position.x < 0: 
		#print("Move Sprite!")
		if get_owner().current_level == 5:
			frame = 5
		else:
			frame = floor(rand_range(0.0,self.frames.get_frame_count(self.animation)))
		var new_pos = Vector2(self.position.x + (2*2020), self.position.y)
		self.position = new_pos
	pass

