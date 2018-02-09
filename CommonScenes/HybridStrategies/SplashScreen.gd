extends ColorFrame

var next_screen_path = "res://JetpackGameMode/JetpackGame.tscn"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func change_scene():
	ScreenManager.load_screen(next_screen_path)
	pass