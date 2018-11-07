extends ParallaxBackground

var game_mode

func _ready():
	game_mode = Global.get_game_mode()
	
	if game_mode == "story":
		load_story_pregame()
	elif game_mode == "arcade":
		load_arcade_pregame()
	elif game_mode == "speedrun":
		load_speedrun_pregame()

func load_story_pregame():
	var path = "res://CommonScenes/LevelSelectMenu/LevelSelectMenu.tscn"
	ScreenManager.load_above(path, self.get_path(), self)

func load_arcade_pregame():
	pass

func load_speedrun_pregame():
	pass
