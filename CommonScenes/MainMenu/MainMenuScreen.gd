extends Node2D

#Menu Paths
export(String, FILE) var options_path = "res://CommonScenes/OptionsMenu/OptionsMenuScreen.tscn"
export(String, FILE) var extras_path = "res://CommonScenes/ExtrasMenu/ExtrasMenuScreen.tscn"
export(String, FILE) var game_path

var continue_btn
var new_game_btn
var arcade_btn
var speedrun_btn
var back_btn
var options_btn
var extras_btn
var quit_btn

var game_mode = "story"
var last_focus
var intro_cutscene = preload("res://Cutscenes/Cutscene1.tscn")

onready var options_scene = load(options_path)
onready var extras_scene = load(extras_path)

func _ready():
	
	continue_btn = get_node("MenuContainer/Continue")
	new_game_btn = get_node("MenuContainer/NewGame")
	arcade_btn = get_node("MenuContainer/ArcadeMode")
	speedrun_btn = get_node("MenuContainer/SpeedrunMode")
	back_btn = get_node("MenuContainer/Back")
	options_btn = get_node("MenuContainer/Options")
	extras_btn = get_node("MenuContainer/Extras")
	quit_btn = get_node("MenuContainer/QuitGame")
	
	toggle_menuitems(game_mode)

func _on_options_pressed():
	last_focus = options_btn
	ScreenManager.load_above(options_scene, last_focus, self, true)

func _on_Extras_pressed():
	last_focus = extras_btn
	ScreenManager.load_above(extras_scene, last_focus, self, true)

func _on_quit_pressed():
	var quit_timer = get_node("MenuContainer/QuitGame/Timer")
	quit_timer.start()
	yield(quit_timer, "timeout")
	get_tree().quit()

func _on_Continue_pressed():
	Global.set_game_mode("story", "select level")
	ScreenManager.load_screen(game_path)

func _on_NewGame_pressed():
	Global.reset_story_progress()
	Global.set_game_mode("story", "level selected")
	
	ScreenManager.load_screen(game_path)


func _on_ArcadeMode_pressed():
	game_mode = "arcade"
	toggle_menuitems(game_mode)

func _on_SpeedrunMode_pressed():
	game_mode = "speedrun"
	toggle_menuitems(game_mode)

func _on_Back_pressed():
	game_mode = "story"
	toggle_menuitems(game_mode)

func toggle_menuitems(game_mode):
	if game_mode == "story":
		get_tree().call_group(0,"categorymenu", "hide")
		get_tree().call_group(0,"mainmenu", "show")
		
		arcade_btn.show()
		speedrun_btn.show()
		
		if Global.is_story_completed():
			arcade_btn.set_disabled(false)
			speedrun_btn.set_disabled(false)
		else:
			arcade_btn.set_disabled(true)
			speedrun_btn.set_disabled(true)
		
		if Global.is_tutorial_completed():
			continue_btn.show()
			continue_btn.grab_focus()
			
			continue_btn.set_focus_neighbour(MARGIN_TOP, quit_btn.get_path())
			quit_btn.set_focus_neighbour(MARGIN_BOTTOM, continue_btn.get_path())
		else:
			continue_btn.hide()
			new_game_btn.grab_focus()
			
			new_game_btn.set_focus_neighbour(MARGIN_TOP, quit_btn.get_path())
			quit_btn.set_focus_neighbour(MARGIN_BOTTOM, new_game_btn.get_path())
		
		arcade_btn.set_focus_neighbour(MARGIN_TOP, "")
		speedrun_btn.set_focus_neighbour(MARGIN_TOP, "")
		
	elif game_mode == "arcade" or game_mode == "speedrun":
		get_tree().call_group(0,"categorymenu", "show")
		get_tree().call_group(0,"mainmenu", "hide")
		
		if game_mode == "arcade":
			arcade_btn.show()
			speedrun_btn.hide()
			
			arcade_btn.set_focus_neighbour(MARGIN_TOP, back_btn.get_path())
			back_btn.set_focus_neighbour(MARGIN_BOTTOM, arcade_btn.get_path())
		else:
			arcade_btn.hide()
			speedrun_btn.show()
			
			speedrun_btn.set_focus_neighbour(MARGIN_TOP, back_btn.get_path())
			back_btn.set_focus_neighbour(MARGIN_BOTTOM, speedrun_btn.get_path())


func _on_Category_pressed(upgrade_points):
	var game_settings = {
			"game mode": game_mode, 
			"sub-mode": String(upgrade_points)
	}
	Global.reset_category_progress(game_settings)
	Global.set_game_mode(game_mode, String(upgrade_points))
	ScreenManager.load_screen(game_path)
