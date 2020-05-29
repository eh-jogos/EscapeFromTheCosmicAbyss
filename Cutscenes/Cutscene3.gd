extends "res://Cutscenes/Cutscenes.gd"

func close():
	get_tree().set_pause(false)
	emit_signal("cutscene_ended")
	if get_tree().get_current_scene() == self:
		for child in get_children():
			child.hide()
	else:
		var credits_scene_path: = "res://CommonScenes/CreditsScene/CreditsScene.tscn"
		ScreenManager.load_screen_invisible(credits_scene_path)

