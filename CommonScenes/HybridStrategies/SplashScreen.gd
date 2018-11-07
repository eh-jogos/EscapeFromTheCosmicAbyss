extends ColorFrame

var next_screen_path = "res://CommonScenes/MainMenu/MainMenuScreen.tscn"

func _ready():
	
	pass

func change_scene():
	ScreenManager.load_screen(next_screen_path)
	pass