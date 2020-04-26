extends Node2D

var end_point
var game
var camera

func _ready():
	end_point = self.get_node("EndPoint")
	game = self.get_tree().get_root().get_node("JetpackGame")
	camera = game.get_node("Camera2D")
	
#	print(camera.get_name())
	
	set_process(true)
	pass

func _process(delta):
#	print("Global Pos: %s | Offset: %s"%[self.get_global_position(), end_point.get_position().x-camera.get_position().x])  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	var limit = end_point.get_global_position().x-(camera.get_position().x-1920/2)  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	
	if limit < 0:
#		print("Move Sprite!")
		var new_pos = Vector2(self.get_position().x + (2*(790+790+790)), self.get_position().y)  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
		self.set_position(new_pos)  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	pass

