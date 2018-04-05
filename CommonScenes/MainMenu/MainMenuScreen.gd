extends Node2D

#Menu Paths
var story_path = "res://JetpackGameMode/JetpackGame.tscn"
var arcade_path
var speedrun_path
var options_path = "res://CommonScenes/OptionsMenu/OptionsMenuScreen.tscn"

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
	var path
	
	if identifier == "story":
		path = story_path
	elif identifier == "arcade":
		path = arcade_path
	elif identifier == "speedrun":
		path = speedrun_path
	
	ScreenManager.load_screen(path)

func _on_options_pressed():
	var path = options_path
	last_focus = options_btn.get_path()
	
	ScreenManager.load_above(path, last_focus, self)

func _on_quit_pressed():
	get_tree().quit()
