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
		while last_unlocked_level < levels_unlocked:
			print("Last: %s | All: %s"%[last_unlocked_level, levels_unlocked])
			var animation_name = 0
			if last_unlocked_level < 10:
				animation_name = "state0%s_transition"%[last_unlocked_level]
			else:
				animation_name = "state%s_transition"%[last_unlocked_level]
			
			print(animation_name)
			map_animator.play(animation_name)
			yield(map_animator, "finished")
			yield(map_animator, "finished")
			last_unlocked_level += 1
		
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
	animator.set_current_animation("base")
	animator.seek(0, true)
	
	last_played_level = Global.savedata["story"]["current level"]
	last_unlocked_level = Global.savedata["story"]["last unlock"]
	levels_unlocked = Global.savedata["story"]["levels unlocked"]
	
	init_level_map()
	
	if last_played_level > levels_unlocked:
		last_played_level = last_unlocked_level
	initial_btn = level_buttons.get_child(last_played_level)
	print(initial_btn.get_name())
	
	animator.play_backwards("close")
	yield(animator,"finished")
	
	unlock_levels()