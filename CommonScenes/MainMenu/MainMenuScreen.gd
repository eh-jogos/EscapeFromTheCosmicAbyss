
extends Node2D

#Menu Paths
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

onready var options_scene = $ResourcePreloader.get_resource("OptionsMenuScreen")
onready var extras_scene = $ResourcePreloader.get_resource("ExtrasMenuScreen")
onready var prompt_legend = $PromptLegendConfirmCancel

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
	
	Global.connect("update_main_menu", self, "_on_Global_update_main_menu")
	ScreenManager.connect("scene_above_cleared", self, "_on_ScreenManager_scene_abovel_cleared")
	
	prompt_legend.fade_in()


func _unhandled_input(event):
	if event.is_action("ui_cancel"):
		get_viewport().set_input_as_handled()
	
	if event.is_action_released("ui_cancel"):
		if game_mode == "story":
			var focus_button: Button = $MenuContainer/QuitGame
			if focus_button.has_focus():
				_on_quit_pressed()
			else:
				focus_button.grab_focus()
		else:
			var focus_button: Button = $MenuContainer/Back
			if focus_button.has_focus():
				_on_Back_pressed()
			else:
				focus_button.grab_focus()


func _on_options_pressed():
	last_focus = options_btn
	prompt_legend.fade_out()
	ScreenManager.load_above(options_scene, last_focus, self, options_scene is PackedScene)

func _on_Extras_pressed():
	last_focus = extras_btn
	prompt_legend.fade_out()
	ScreenManager.load_above(extras_scene, last_focus, self, options_scene is PackedScene)

func _on_quit_pressed():
	var quit_timer = get_node("MenuContainer/QuitGame/Timer")
	quit_timer.start()
	yield(quit_timer, "timeout")
	Global.quit_game()

func _on_Continue_pressed():
	Global.set_game_mode("story", "select level")
	prompt_legend.fade_out()
	ScreenManager.load_screen(game_path)

func _on_NewGame_pressed():
	Global.reset_story_progress()
	Global.set_game_mode("story", "level selected")
	prompt_legend.fade_out()
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

func toggle_menuitems(should_grab_focus = true):
	if game_mode == "story":
		get_tree().call_group("categorymenu", "hide")
		get_tree().call_group("mainmenu", "show")
		
		arcade_btn.show()
		speedrun_btn.show()
		
		if Global.is_story_completed():
			arcade_btn.set_disabled(false)
			arcade_btn.focus_mode = Control.FOCUS_ALL
			speedrun_btn.set_disabled(false)
			speedrun_btn.focus_mode = Control.FOCUS_ALL
		else:
			arcade_btn.set_disabled(true)
			arcade_btn.focus_mode = Control.FOCUS_NONE
			speedrun_btn.set_disabled(true)
			speedrun_btn.focus_mode = Control.FOCUS_NONE
		
		if Global.is_tutorial_completed():
			continue_btn.show()
			if should_grab_focus:
				continue_btn.grab_focus()
			
			continue_btn.set_focus_neighbour(MARGIN_TOP, quit_btn.get_path())
			new_game_btn.set_focus_neighbour(MARGIN_TOP, "")
			quit_btn.set_focus_neighbour(MARGIN_BOTTOM, continue_btn.get_path())
		else:
			continue_btn.hide()
			if should_grab_focus:
				new_game_btn.grab_focus()
			
			continue_btn.set_focus_neighbour(MARGIN_TOP, "")
			new_game_btn.set_focus_neighbour(MARGIN_TOP, quit_btn.get_path())
			quit_btn.set_focus_neighbour(MARGIN_BOTTOM, new_game_btn.get_path())
		
		arcade_btn.set_focus_neighbour(MARGIN_TOP, "")
		speedrun_btn.set_focus_neighbour(MARGIN_TOP, "")
		
	elif game_mode == "arcade" or game_mode == "speedrun":
		get_tree().call_group("categorymenu", "show")
		get_tree().call_group("mainmenu", "hide")
		
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


func _on_Global_update_main_menu():
	game_mode = "story"
	toggle_menuitems(false)


func _on_ScreenManager_scene_abovel_cleared(back_to_scene: Node) -> void:
	if self == back_to_scene:
		prompt_legend.fade_in()
