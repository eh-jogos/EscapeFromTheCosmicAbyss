extends Node2D

# class member variables go here, for example:
var game
var tutorial3_heat_bar

var btn_exit

var previous_state
var previous_focus

func _ready():
	game = self.get_parent().get_parent()
	tutorial3_heat_bar = self.get_node("HUD/TextureProgress/AnimationPlayer")
	
	btn_exit = self.get_node("ExitTutorial")
	pass

func play(previous = null):
	previous_state = game.get_game_state()
	previous_focus = previous
	
	game.set_game_state("Tutorial")
	self.show()
	btn_exit.grab_focus()
	
	

func _on_exit_tutorial():
	if not Global.savedata["how to play"]:
		Global.savedata["how to play"] = true
		Global.save()
		
	if previous_state == 0:
		self.hide()
		
		game.game_start()
	else:
		self.hide()
		game.set_game_state("Pause")
		if previous_focus != null:
			previous_focus.grab_focus()
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

