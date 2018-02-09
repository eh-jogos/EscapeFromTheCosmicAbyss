extends Node2D

# class member variables go here, for example:
var game
var tutorial3_heat_bar

var btn_exit

var is_paused = false

func _ready():
	game = self.get_parent().get_parent()
	tutorial3_heat_bar = self.get_node("HUD/TextureProgress/AnimationPlayer")
	
	btn_exit = self.get_node("ExitTutorial")
	pass

func play():
	self.show()
	btn_exit.grab_focus()

func _on_exit_tutorial():
	if not Global.savedata["how to play"]:
		Global.savedata["how to play"] = true
		Global.save()
		
	if not is_paused:
		self.hide()
		
		game.game_start()
	else:
		self.hide()
	pass # replace with function body

func undashable(boolean):
	if boolean:
		tutorial3_heat_bar.play("undashable")
	else:
		tutorial3_heat_bar.play_backwards("undashable")

func overheat(boolean):
	if boolean:
		tutorial3_heat_bar.play("overheated")
	else:
		tutorial3_heat_bar.play_backwards("overheated")

