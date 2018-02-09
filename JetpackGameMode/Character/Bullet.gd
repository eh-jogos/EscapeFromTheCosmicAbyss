extends Area2D

# class member variables go here, for example:
var camera

var speed = 40

func _ready():
	camera = get_node("../..").get_node("Camera2D")
	set_fixed_process(true)
	pass

func _fixed_process(delta):
	var new_pos = self.get_pos()+Vector2(speed,0)
	self.set_pos(new_pos)
	
	var pipes = get_overlapping_bodies()
	if self.get_overlapping_bodies().size() == 1:
		pipes[0].emit_signal("die")
		self.queue_free()
	
	var limit = self.get_global_pos().x-(camera.get_pos().x+1920/2)
	
	if limit > 0:
		self.queue_free()