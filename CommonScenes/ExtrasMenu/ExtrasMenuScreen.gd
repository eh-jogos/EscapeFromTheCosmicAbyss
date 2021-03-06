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

onready var state_animator = $StatePlayer

func _ready():
	var last_unlocked_level = Global.savedata["story"]["last unlock"]
	
	credits = get_node("MenuContainer/Credits")
	intro = get_node("MenuContainer/Intro")
	level5 = get_node("MenuContainer/Level5")
	ending = get_node("MenuContainer/Ending")
	back = get_node("MenuContainer/Back")
	
	ScreenManager.connect("mid_transition_reached", self, "_on_ScreenManager_mid_transition_reached")
	
	var buttons = [credits, intro, level5, ending]
	for button in buttons:
		button.set_disabled(true)
		button.focus_mode = Control.FOCUS_NONE
		if not button.is_connected("pressed", self, "_on_button_pressed"):
			button.connect("pressed", self, "_on_button_pressed", [button])
	
	if credits_scene_path == "":
		intro.focus_neighbour_top = intro.get_path_to(back)
	else:
		credits.set_disabled(false)
		credits.focus_mode = Control.FOCUS_ALL
	
	if Global.is_tutorial_completed() or Global.is_story_completed():
		intro.set_disabled(false)
		intro.focus_mode = Control.FOCUS_ALL
		if back.has_focus():
			intro.grab_focus()
	
	if last_unlocked_level > 5 or Global.is_story_completed():
		level5.set_disabled(false)
		level5.focus_mode = Control.FOCUS_ALL
	
	if Global.is_story_completed():
		ending.set_disabled(false)
		ending.focus_mode = Control.FOCUS_ALL
	
	
	animator = self.get_node("AnimationPlayer")
	animator.play("open")


func _unhandled_input(event):
	if event.is_action("ui_cancel"):
		get_viewport().set_input_as_handled()
	
	if event.is_action_released("ui_cancel"):
		var focus_button: Button
		var back_to_extras = $AchievementsMenu/BackToExtras
		if state_animator.assigned_animation == "achievements_menu":
			focus_button = back_to_extras
		else:
			focus_button = back
		
		if focus_button.has_focus():
			if focus_button == back:
				_on_Back_pressed()
			elif focus_button == back_to_extras:
				_on_BackToExtras_pressed()
			else:
				_on_Back_pressed()
		else:
			focus_button.grab_focus()


func _on_button_pressed(node):
	var path
	if node == credits:
		Global.was_credits_called_from_extras = true
		path = credits_scene_path
	elif node == intro:
		path = cutscene_intro_path
	elif node == level5:
		path = cutscene_level5_path
	elif node == ending:
		Global.was_ending_called_from_extras = true
		path = cutscene_ending_path
	else:
		print("ERROR | INVALID BUTTON PRESSED: %s"%node)
	
	ScreenManager.black_transition(path, node, self)

func _on_Back_pressed():
	animator.play("close")
	SoundManager.play_sfx("Confirm")
	yield(animator, "animation_finished")
	ScreenManager.clear_above()


func _on_ScreenManager_mid_transition_reached():
	var legend_confirm_cancel: BaseLegend = $LegendConfirmCancel
	var menu_container: VBoxContainer = $MenuContainer
	var bg_dark = $ColorFrame1
	var bg_screen = $ColorFrame2
	if ScreenManager.scene_above == self:
		animator.assigned_animation = "open"
		animator.seek(animator.current_animation_length, true)
		legend_confirm_cancel.show()
		menu_container.show()
		bg_dark.show()
		bg_screen.show()
	else:
		animator.assigned_animation = "close"
		animator.seek(animator.current_animation_length, true)
		legend_confirm_cancel.hide()
		menu_container.hide()
		bg_dark.hide()
		bg_screen.hide()


func _on_Achievements_pressed():
	state_animator.play("achievements_menu")


func _on_BackToExtras_pressed():
	state_animator.play("extras_menu")
