extends StaticBody2D

var end_point
var game
var camera

signal reset
signal scored
signal kill_player
signal die

func _ready():
	end_point = self.get_node("EndPoint")
	game = self.get_tree().get_root().get_node("JetpackGame")
	camera = game.get_node("Camera2D")
	
#	print(camera.get_name())
	
	set_process(true)
	pass

func _process(delta):
#	print("Global Pos: %s | Offset: %s"%[self.get_global_pos(), end_point.get_pos().x-camera.get_pos().x])
	var limit = end_point.get_global_pos().x-(camera.get_pos().x-1920/2)
	
	if limit < 0:
#		print("Move Sprite!")
		var new_pos = Vector2(self.get_pos().x + (2*(790+790+790)), self.get_pos().y)
		self.set_pos(new_pos)
		emit_signal("reset")
	pass


func _on_player_killed():
	game.game_over()
