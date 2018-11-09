extends Node2D

#Menu Paths
export(String, FILE) var pregame_path = "res://CommonScenes/PreGameScreen/PreGame.tscn"
export(String, FILE) var options_path = "res://CommonScenes/OptionsMenu/OptionsMenuScreen.tscn"
export(String, FILE) var game_path

var story_btn
var arcade_btn
var speedrun_btn
var options_btn
var quit_btn


var last_focus

func _ready():
	story_btn = get_node("MenuContainer/StoryMode")
	arcade_btn = get_node("MenuContainer/ArcadeMode")
	speedrun_btn = get_node("MenuContainer/SpeedrunMode")
	options_btn = get_node("MenuContainer/Options")
	quit_btn = get_node("MenuContainer/QuitGame")
	
	story_btn.grab_focus()


func _on_button_pressed(identifier):
	Global.set_game_mode(identifier)
	if identifier == "story" and not has_completed_tutorial():
		ScreenManager.load_screen(game_path)
	else:
		ScreenManager.load_screen(pregame_path)

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
