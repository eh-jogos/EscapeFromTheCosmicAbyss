extends AnimatedSprite

var end_point

func _ready():
	end_point = self.get_node("EndPoint")
	
	set_process(true)
	pass

func _process(delta):
	#print("Global Pos: %s | Pos: %s"%[self.get_global_position(), self.get_position()])  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	if end_point.get_global_position().x < 0:  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
		#print("Move Sprite!")
		var frame = floor(rand_range(0.0,5.0))
		self.set_frame(frame)
		var new_pos = Vector2(self.get_position().x + (2*2020), self.get_position().y)  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
		self.set_position(new_pos)  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	pass
