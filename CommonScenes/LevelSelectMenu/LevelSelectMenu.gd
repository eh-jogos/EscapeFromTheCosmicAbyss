extends CanvasLayer

var level_buttons
var initial_btn
var animator
var map_animator

# Stats Variables imported from savedata
var last_played_level
var last_unlocked_level
var levels_unlocked

####################
# Internal Methods #
####################

func init_level_map():
	var animation_name = 0
	if levels_unlocked == 0:
		animation_name = "state01"
	elif levels_unlocked < 10:
		animation_name = "state0%s"%[last_unlocked_level]
	else:
		animation_name = "state%s"%[last_unlocked_level]
	
	print(animation_name)
	map_animator.play(animation_name)

func unlock_levels():
	if last_unlocked_level < levels_unlocked:
		var animations_to_play: = []
		while last_unlocked_level < levels_unlocked :
			print("Last: %s | All: %s"%[last_unlocked_level, levels_unlocked])
			var animation_name = 0
			if last_unlocked_level < 10:
				animation_name = "state0%s_transition"%[last_unlocked_level]
			else:
				animation_name = "state%s_transition"%[last_unlocked_level]
			animations_to_play.push_back(animation_name)
			last_unlocked_level += 1
		
		for animation_name in animations_to_play:
			print("Playing animation: %s"%[animation_name])
			map_animator.play(animation_name)
			yield(get_tree().create_timer(map_animator.current_animation_length), "timeout")
		
		print("Last: %s | All: %s"%[last_unlocked_level, levels_unlocked])
		Global.update_story_last_unlock(last_unlocked_level)
	elif last_unlocked_level > levels_unlocked:
		print("ERROR | Last Unlocked Level > levels_unlocked")
		print("Last Unlock: %s | Levels Unlocked: %s"%[last_unlocked_level, levels_unlocked])
	else:
		initial_btn.grab_focus()


##################
# Engine Methods #
##################

func _ready():
	level_buttons = get_node("Map/LevelButtons")
	map_animator = self.get_node("Map/AnimationPlayer")
	
	animator = self.get_node("AnimationPlayer")
	animator.assigned_animation = "base"
	animator.seek(0, true)
	
	last_played_level = Global.savedata["story"]["current level"]
	last_unlocked_level = Global.savedata["story"]["last unlock"] 
	levels_unlocked = Global.savedata["story"]["levels unlocked"]
	
	if OS.has_feature("demo") or get_tree().get_current_scene() == self:
		levels_unlocked = min(levels_unlocked, 5)
		last_unlocked_level = min(last_unlocked_level, 5)
	
	init_level_map()
	
	if last_played_level > levels_unlocked:
		last_played_level = last_unlocked_level
	initial_btn = level_buttons.get_child(last_played_level)
	
	if is_above_some_menu():
		print("Screen Below: %s "%[ScreenManager.scenes_bellow[0].name])
		$LegendLevelSelect.show_cancel_prompt()
	else:
		$LegendLevelSelect.hide_cancel_prompt()
	
	animator.play("open")
	yield(animator, "animation_finished")
	
	unlock_levels()


func _unhandled_input(event):
	if event.is_action("ui_cancel"):
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("ui_cancel") and is_above_some_menu():
		ScreenManager.clear_above()


func is_above_some_menu():
	if ScreenManager.scenes_bellow.size() > 0:
		return ScreenManager.scenes_bellow[0].name != "JetpackGame"
	else:
		return false
