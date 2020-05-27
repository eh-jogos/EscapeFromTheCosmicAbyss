extends ColorRect  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review

var next_screen_path = "res://CommonScenes/MainMenu/MainMenuScreen.tscn"

func change_scene():
	ScreenManager.load_screen_invisible(next_screen_path)
	pass

func reveal_loading_screen():
#	ScreenManager.reveal_invisible_loading_screen()
	pass
