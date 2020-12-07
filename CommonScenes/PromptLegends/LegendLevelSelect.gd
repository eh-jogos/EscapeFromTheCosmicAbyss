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
	pass

### ---------------------------------------


### Public Methods ------------------------
func show_cancel_prompt():
	$RootControl/LegendContainer/CancelPrompt.show()


func hide_cancel_prompt():
	$RootControl/LegendContainer/CancelPrompt.hide()
### ---------------------------------------


### Private Methods -----------------------

### ---------------------------------------
