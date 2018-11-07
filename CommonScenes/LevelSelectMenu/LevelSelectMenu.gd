extends CanvasLayer

var level_buttons
var initial_btn
var animator

# Stats Variables imported from savedata


####################
# Internal Methods #
####################

func init_level_map():
	#cooldown = Global.savedata["story"]["cooldown"]
	pass

func _on_Close_pressed():
	animator.play("close")
	yield(animator,"finished")
	ScreenManager.clear_above()

##################
# Engine Methods #
##################

func _ready():
	var last_played_level = Global.savedata["story"]["current level"]
	level_buttons = get_node("Map/LevelButtons")
	initial_btn = level_buttons.get_child(last_played_level)
	initial_btn.grab_focus()
	
	animator = self.get_node("AnimationPlayer")
	animator.play_backwards("close")
	pass