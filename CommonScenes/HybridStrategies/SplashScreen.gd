extends ColorFrame

var next_screen_path = "res://CommonScenes/MainMenu/MainMenuScreen.tscn"

func _ready():
	Global.check_savefile()
	pass

func change_scene():
	ScreenManager.load_screen(next_screen_path)
	pass