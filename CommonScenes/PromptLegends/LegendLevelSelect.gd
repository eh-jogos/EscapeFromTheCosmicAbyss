extends BaseLegend
# Write your doc striing for this file here

### Member Variables and Dependencies -----
# signals 
# enums
# constants
# public variables - order: export > normal var > onready 
# private variables - order: export > normal var > onready 
### ---------------------------------------


### Built in Engine Methods ---------------
func _ready():
	ScreenManager.connect("scene_above_cleared", self, "_on_ScreenManager_scene_above_cleared")
	pass

### ---------------------------------------


### Public Methods ------------------------
func show_cancel_prompt():
	$RootControl/LegendContainer/CancelPrompt.show()


func hide_cancel_prompt():
	$RootControl/LegendContainer/CancelPrompt.hide()
### ---------------------------------------


### Private Methods -----------------------

func _on_ScreenManager_scene_above_cleared(current_scene: Node) -> void:
	if current_scene == owner:
		show()

### ---------------------------------------
