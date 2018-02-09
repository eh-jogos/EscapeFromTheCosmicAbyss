extends Sprite

var end_point
var camera

func _ready():
	end_point = self.get_node("EndPoint")
	
	randomize()
	set_process(true)
	pass

func _process(delta):
	#print("Global Pos: %s | Pos: %s"%[self.get_global_pos(), self.get_pos()])
	if end_point.get_global_pos().x < 0:
		var new_pos = Vector2(self.get_pos().x + (4*1920), self.get_pos().y)
		var flip_h = int(rand_range(0,2))
		var flip_v = int(rand_range(0,2))
		
		self.set_pos(new_pos)
		
		if flip_h == 0:
			self.set_flip_h(false)
		elif flip_h == 1:
			self.set_flip_h(true)
		
		if flip_v == 0:
			self.set_flip_v(false)
		elif flip_v == 1:
			self.set_flip_v(true)
	pass