extends CanvasLayer

var fullscreen_btn
var animator
var debug_count = 0

func _ready():
	fullscreen_btn = get_node("MenuContainer/FullscreenOption")
	fullscreen_btn.grab_focus()
	
	animator = self.get_node("AnimationPlayer")
	animator.assigned_animation = "close"
	animator.seek(animator.current_animation_length, true)
	animator.play_backwards("close")
	
	ScreenManager.connect("mid_transition_reached", self, "_on_ScreenManager_mid_transition_reached")
	
	if OS.is_debug_build():
		_toggle_debug_menu(true)
	else:
		_toggle_debug_menu(false)


func _toggle_debug_menu(value):
	var debug_menu_container = get_node("MenuContainer/DebugMenu")
	
	debug_menu_container.visible = !(!value)  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	for button in debug_menu_container.get_children():
		button.set_disabled(!value)


func _on_ScreenManager_mid_transition_reached():
	if ScreenManager.scene_above == self:
		animator.seek(0, true)
	else:
		animator.seek(animator.current_animation_length, true)


func _on_options_exit_pressed():
	Global.save()
	SoundManager.stop_preview_bgm()
	SoundManager.change_bgm_track()
	
	animator.play("close")
	
	yield(animator, "animation_finished")
	
	ScreenManager.clear_above()


func _on_Restart_pressed():
	get_tree().change_scene("res://CommonScenes/HybridStrategies/SplashScreen.tscn")
	ScreenManager.reset_above_below()


func _on_ResetSave_pressed():
	Global.reset_savefile()
	Global.emit_signal("update_main_menu")


func _on_UnlockEverything_pressed():
	Global.update_story_unlocks(12)
	Global.update_story_last_unlock(12)
	Global.set_current_story_level(12)
	Global.tutorial_completed()
	Global.story_completed()
	Global.emit_signal("update_main_menu")


func _on_DebugButton_pressed():
	var debug_menu_container = get_node("MenuContainer/DebugMenu")
	var debug_timer = get_node("DebugButton/DebugTimer")
	var is_visible = debug_menu_container.is_visible()
	debug_count += 1
	if debug_count >= 5 or is_visible:
		debug_count = 0
		debug_timer.stop()
		_toggle_debug_menu(!is_visible)
	else:
		debug_timer.stop()
		debug_timer.start()


func _on_DebugTimer_timeout():
	debug_count = 0



func _on_EditColors_pressed():
	var colors_menu = $ResourcePreloader.get_resource("ColorsMenu")
	ScreenManager.black_transition(colors_menu, $MenuContainer/EditColors, self, true)
