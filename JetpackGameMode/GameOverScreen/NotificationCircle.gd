extends TextureRect
# Write your doc striing for this file here

### Member Variables and Dependencies -----
# signals 
# enums
# constants
# public variables - order: export > normal var > onready 
# private variables - order: export > normal var > onready 

onready var _label: Label = $Label
### ---------------------------------------


### Built in Engine Methods ---------------
func _ready():
	hide()

### ---------------------------------------


### Public Methods ------------------------
func set_notification_points(points: int) -> void:
	if points <= 0:
		hide()
	else:
		show()
		_label.text = "%s"%[points]

### ---------------------------------------


### Private Methods -----------------------

### ---------------------------------------
