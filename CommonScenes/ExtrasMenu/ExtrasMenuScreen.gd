extends CanvasLayer

export(String, FILE, "*.tscn") var credits_scene_path
export(String, FILE, "*.tscn") var cutscene_intro_path
export(String, FILE, "*.tscn") var cutscene_level5_path
export(String, FILE, "*.tscn") var cutscene_almost_path
export(String, FILE, "*.tscn") var cutscene_ending_path

# node variables
var credits
var intro
var level5
var almost
var ending
var back
var animator

func _ready():
	var last_unlocked_level = Global.savedata["story"]["last unlock"]
	
	credits = get_node("MenuContainer/Credits")
	intro = get_node("MenuContainer/Intro")
	level5 = get_node("MenuContainer/Level5")
	almost = get_node("MenuContainer/Almost")
	ending = get_node("MenuContainer/Ending")
	back = get_node("MenuContainer/Back")
	
	var buttons = [credits, intro, level5, almost, ending]
	for button in buttons:
		button.set_disabled(true)
		if not button.is_connected("pressed", self, "_on_button_pressed"):
			button.connect("pressed", self, "_on_button_pressed", [button])
	
	if Global.is_tutorial_completed():
		intro.set_disabled(false)
	
	if last_unlocked_level > 5:
		level5.set_disabled(false)
	
	if last_unlocked_level == 12:
		almost.set_disabled(false)
	
	if Global.is_story_completed():
		ending.set_disabled(false)
	
	if credits_scene_path == null:
		back.grab_focus()
	else:
		credits.set_disabled(false)
		credits.grab_focus()
	
	animator = self.get_node("AnimationPlayer")
	animator.play_backwards("close")


func _on_button_pressed(node):
	var path
	if node == credits:
		path = credits_scene_path
	elif node == intro:
		path = cutscene_intro_path
	elif node == level5:
		path = cutscene_level5_path
	elif node == almost:
		path = cutscene_almost_path
	elif node == ending:
		path = cutscene_ending_path
	else:
		print("ERROR | INVALID BUTTON PRESSED: %s"%node)
	
	ScreenManager.black_transition(path, node, self)

func _on_Back_pressed():
	animator.play("close")
	yield(animator,"finished")
	ScreenManager.clear_above()
