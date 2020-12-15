extends StaticBody2D

var end_point
var game
var darkwave_brain

func _ready():
	end_point = self.get_node("EndPoint")
	game = self.get_tree().get_root().get_node("JetpackGame")
	darkwave_brain = self.get_node("DarkWaveBrain")
	
#	print(game.camera.get_name())
	
	set_process(true)
	pass

func _process(_delta):
#	print("Global Pos: %s | Offset: %s"%[self.global_position, end_point.position.x-camera.position.x])
	var limit = end_point.global_position.x-(game.camera.position.x-1920/2)
	
	if limit < 0:
#		print("Move Sprite!")
		var new_pos = Vector2(self.position.x + (2*(790+790+790)), self.position.y)
		self.position = new_pos
	pass


func kill_player(offset):
	var flip_dead_player = false
	if offset.y < 1080/2:
		flip_dead_player = true
	
	# 480 is the offset of the player sprite in the player scene
	var offset_x = offset.x - 480
	darkwave_brain._on_kill_player(offset_x, flip_dead_player)
	pass


func shake_camera() -> void:
	Global.emit_signal("shake_trauma_added", 6.0)


func _on_player_killed():
	game.game_over()
