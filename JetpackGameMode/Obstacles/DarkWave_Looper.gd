extends StaticBody2D

var end_point
var game
var camera
var darkwave_brain

func _ready():
	end_point = self.get_node("EndPoint")
	game = self.get_tree().get_root().get_node("JetpackGame")
	camera = game.get_node("Camera2D")
	darkwave_brain = self.get_node("DarkWaveBrain")
	
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
	pass


func kill_player(offset):
	var flip_dead_player = false
	if offset.y < 1080/2:
		flip_dead_player = true
	
	# 480 is the offset of the player sprite in the player scene
	var offset_x = offset.x - 480
	darkwave_brain._on_kill_player(offset_x, flip_dead_player)
	pass

func _on_player_killed():
	game.game_over()


func stop_all_sfx():
	var sfx_player = get_node("SamplePlayer")
	sfx_player.stop_all()