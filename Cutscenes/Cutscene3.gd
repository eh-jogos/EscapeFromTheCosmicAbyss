extends "res://Cutscenes/Cutscenes.gd"

func close():
	get_tree().set_pause(false)
	emit_signal("cutscene_ended")
	if get_tree().get_current_scene() == self:
		for child in get_children():
			child.hide()
	else:
		if Global.was_ending_called_from_extras:
			Global.was_ending_called_from_extras = false
			ScreenManager.black_transition_from_above()
		else:
			if not Global.achievements_handler.has_changed_the_univese:
				Global.achievements_handler.has_changed_the_univese = true
				Global.achievements_handler.emit_signal("changed_the_universe_achieved")
				Global.achievements_handler.save()
			var credits_scene_path: = "res://CommonScenes/CreditsScene/CreditsScene.tscn"
			ScreenManager.load_screen_invisible(credits_scene_path)

