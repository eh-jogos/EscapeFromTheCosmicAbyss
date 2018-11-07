extends CanvasLayer

export(NodePath) var initial_btn_path
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
	initial_btn = get_node(initial_btn_path)
	initial_btn.grab_focus()
	
	animator = self.get_node("AnimationPlayer")
	animator.play_backwards("close")
	pass