extends "res://JetpackGameMode/BG/BG_LooperH.gd"

func _process(delta):
	#print("Global Pos: %s | Pos: %s"%[self.get_global_pos(), self.get_pos()])
	if end_point.get_global_pos().x < 0:
		#print("Move Sprite!")
		var frame = floor(rand_range(0.0,5.0))
		if get_owner().current_level == 5:
			frame = 2
		self.set_frame(frame)
		var new_pos = Vector2(self.get_pos().x + (2*2020), self.get_pos().y)
		self.set_pos(new_pos)
	pass
