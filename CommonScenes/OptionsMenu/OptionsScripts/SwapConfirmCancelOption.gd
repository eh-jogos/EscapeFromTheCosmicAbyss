extends BaseArrowsButton
# Write your doc striing for this file here

### Member Variables and Dependencies -----
# signals 
# enums
# constants
const text_string = "Swap Menus Confirm/Cancel: %s"

# export variables
# public variables
# private variables
var _is_swapped: = false

# onready variables
### ---------------------------------------


### Built in Engine Methods ---------------

func _ready():
	_is_swapped = JoypadSupport.was_ui_accept_manually_swapped()
	_handle_text()

### ---------------------------------------


### Public Methods ------------------------
func change_option() -> void:
	_play_change_sfx()
	_is_swapped = !_is_swapped
	JoypadSupport.swap_ui_accept_and_cancel(_is_swapped)
	_handle_text()

### ---------------------------------------


### Private Methods -----------------------
func _handle_text():
	if _is_swapped:
		text = text_string%["On"]
	else:
		text = text_string%["Off"]

### ---------------------------------------


