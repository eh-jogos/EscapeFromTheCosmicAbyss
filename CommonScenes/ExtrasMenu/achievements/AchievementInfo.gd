extends VBoxContainer
# Write your doc striing for this file here

### Member Variables and Dependencies -----
# signals 
# enums
# constants
# public variables - order: export > normal var > onready 
# private variables - order: export > normal var > onready 
onready var _title = $Title
onready var _description = $Description
### ---------------------------------------


### Built in Engine Methods ---------------
func _ready():
	Global.connect("achievement_info_sent", self, "_on_Global_achievement_info_sent")
### ---------------------------------------


### Public Methods ------------------------

### ---------------------------------------


### Private Methods -----------------------
func _on_Global_achievement_info_sent(title: String, description: String):
	_title.text = title
	_description.text = description

### ---------------------------------------
