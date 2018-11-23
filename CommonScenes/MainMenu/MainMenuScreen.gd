extends Node2D

#Menu Paths
export(String, FILE) var pregame_path = "res://CommonScenes/PreGameScreen/PreGame.tscn"
export(String, FILE) var options_path = "res://CommonScenes/OptionsMenu/OptionsMenuScreen.tscn"
export(String, FILE) var game_path

var continue_btn
var new_game_btn
var arcade_btn
var speedrun_btn
var options_btn
var quit_btn


var last_focus

func _ready():
	continue_btn = get_node("MenuContainer/Continue")
	new_game_btn = get_node("MenuContainer/NewGame")
	arcade_btn = get_node("MenuContainer/ArcadeMode")
	speedrun_btn = get_node("MenuContainer/SpeedrunMode")
	options_btn = get_node("MenuContainer/Options")
	quit_btn = get_node("MenuContainer/QuitGame")
	
	if has_completed_tutorial():
		continue_btn.show()
		continue_btn.grab_focus()
	else:
		continue_btn.hide()
		new_game_btn.grab_focus()


func _on_options_pressed():
	var path = options_path
	last_focus = options_btn.get_path()
	
	ScreenManager.load_above(path, last_focus, self)

func _on_quit_pressed():
	get_tree().quit()

func has_completed_tutorial():
	if Global.savedata["story"]["levels unlocked"] == 0:
		return false
	else:
		return true


func _on_Continue_pressed():
	Global.set_game_mode("story", "select level")
	ScreenManager.load_screen(game_path)

func _on_NewGame_pressed():
	Global.reset_story_progress()
	Global.set_game_mode("story", "select level")
	#TO DO - Load Intro instead of game.
	ScreenManager.load_screen(game_path)


func _on_ArcadeMode_pressed():
	pass


func _on_SpeedrunMode_pressed():
	pass