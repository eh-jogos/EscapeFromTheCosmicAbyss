extends CanvasLayer

export(String, FILE, "*.tscn") var credits_scene_path
export(String, FILE, "*.tscn") var cutscene_intro_path
export(String, FILE, "*.tscn") var cutscene_level5_path
export(String, FILE, "*.tscn") var cutscene_ending_path

# node variables
var credits
var intro
var level5
var ending
var back
var animator

func _ready():
	var last_unlocked_level = Global.savedata["story"]["last unlock"]
	
	credits = get_node("MenuContainer/Credits")
	intro = get_node("MenuContainer/Intro")
	level5 = get_node("MenuContainer/Level5")
	ending = get_node("MenuContainer/Ending")
	back = get_node("MenuContainer/Back")
	
	var buttons = [credits, intro, level5, ending]
	for button in buttons:
		button.set_disabled(true)
		button.focus_mode = Control.FOCUS_NONE
		if not button.is_connected("pressed", self, "_on_button_pressed"):
			button.connect("pressed", self, "_on_button_pressed", [button])
	
	if Global.is_tutorial_completed() or Global.is_story_completed():
		intro.set_disabled(false)
		intro.focus_mode = Control.FOCUS_ALL
	
	if last_unlocked_level > 5 or Global.is_story_completed():
		level5.set_disabled(false)
		level5.focus_mode = Control.FOCUS_ALL
	
	if Global.is_story_completed():
		ending.set_disabled(false)
		ending.focus_mode = Control.FOCUS_ALL
	
	if credits_scene_path == "":
		back.grab_focus()
		intro.focus_neighbour_top = intro.get_path_to(back)
	else:
		credits.set_disabled(false)
		credits.focus_mode = Control.FOCUS_ALL
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
	elif node == ending:
		path = cutscene_ending_path
	else:
		print("ERROR | INVALID BUTTON PRESSED: %s"%node)
	
	ScreenManager.black_transition(path, node, self)

func _on_Back_pressed():
	animator.play("close")
	yield(animator, "animation_finished")
	ScreenManager.clear_above()

